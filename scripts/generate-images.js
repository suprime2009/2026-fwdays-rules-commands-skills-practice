#!/usr/bin/env node

/**
 * OpenAI Image Generation Script for Slidev Presentation
 * Generates images for presentation slides using DALL-E API
 *
 * Usage:
 *   node scripts/generate-images.js [slide-topic] [output-path]
 *
 * Environment variables:
 *   OPENAI_API_KEY - Your OpenAI API key
 *
 * Examples:
 *   node scripts/generate-images.js "AI assistant helping developer" images/ai-assistant.png
 *   OPENAI_API_KEY=sk-... node scripts/generate-images.js "workflow diagram" images/workflow.png
 */

const fs = require('fs').promises;
const path = require('path');
const https = require('https');

// Check for OpenAI API key
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
if (!OPENAI_API_KEY) {
  console.error('❌ OPENAI_API_KEY environment variable is required');
  console.log('Set it with: export OPENAI_API_KEY="your-api-key-here"');
  process.exit(1);
}

// OpenAI API configuration
const API_BASE = 'https://api.openai.com/v1';
const HEADERS = {
  'Authorization': `Bearer ${OPENAI_API_KEY}`,
  'Content-Type': 'application/json',
};

// Predefined prompts for different slide types
const PROMPTS = {
  'ai-concept': 'Digital brain with neural networks connected to a code editor, futuristic AI assistant helping developer write code, glowing blue circuits, high-tech interface, professional technology illustration',
  'workflow': 'Clean flowchart diagram showing AI-powered software development workflow: Plan → Code → Test → Deploy, with AI assistant icons, arrows and boxes, modern minimal design, blue and green color scheme',
  'architecture': 'System architecture diagram with AI components, neural networks, data flow arrows, cloud infrastructure, microservices, modern tech stack visualization',
  'ai-assistant': 'Friendly AI assistant robot helping programmer write code, modern flat design, blue and purple colors, minimal style, technology icon',
  'code-editor': 'Modern code editor interface with AI suggestions, syntax highlighting, intelligent autocomplete, dark theme, developer tools',
  'neural-network': 'Abstract neural network visualization, interconnected nodes, data flow, AI brain representation, digital technology pattern',
  'data-flow': 'Data flow diagram showing information processing through AI system, arrows and connections, clean minimal design, technology theme'
};

/**
 * Download image from URL and save to file
 */
async function downloadImage(url, outputPath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(outputPath);

    https.get(url, (response) => {
      if (response.statusCode !== 200) {
        reject(new Error(`Failed to download image: ${response.statusCode}`));
        return;
      }

      response.pipe(file);

      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(outputPath, () => {}); // Delete the file on error
      reject(err);
    });
  });
}

/**
 * Generate image using OpenAI DALL-E API
 */
async function generateImage(prompt, options = {}) {
  const {
    size = '1024x1024',
    quality = 'standard',
    style = 'vivid'
  } = options;

  const requestBody = {
    model: 'dall-e-3',
    prompt: prompt,
    size: size,
    quality: quality,
    style: style,
    n: 1,
  };

  console.log('🎨 Generating image with prompt:', prompt.substring(0, 100) + '...');

  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(requestBody);

    const req = https.request(
      `${API_BASE}/images/generations`,
      {
        method: 'POST',
        headers: {
          ...HEADERS,
          'Content-Length': Buffer.byteLength(postData),
        },
      },
      (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          if (res.statusCode === 200) {
            try {
              const response = JSON.parse(data);
              resolve(response);
            } catch (err) {
              reject(new Error('Failed to parse API response'));
            }
          } else {
            reject(new Error(`API request failed: ${res.statusCode} - ${data}`));
          }
        });
      }
    );

    req.on('error', (err) => {
      reject(err);
    });

    req.write(postData);
    req.end();
  });
}

/**
 * Generate image for a specific slide topic
 */
async function generateSlideImage(topic, outputPath, customPrompt = null) {
  try {
    // Ensure output directory exists
    const outputDir = path.dirname(outputPath);
    await fs.mkdir(outputDir, { recursive: true });

    // Get prompt
    let prompt = customPrompt;
    if (!prompt) {
      prompt = PROMPTS[topic] || `Professional technical illustration for presentation slide about ${topic}, modern design, technology theme, clean and minimal`;
    }

    // Add Ukrainian language context for better results
    prompt += ', suitable for Ukrainian developer audience, professional presentation style';

    console.log(`🚀 Generating image for topic: "${topic}"`);
    console.log(`📁 Output path: ${outputPath}`);

    // Generate image
    const response = await generateImage(prompt, {
      size: '1024x1024',
      quality: 'standard',
      style: 'vivid'
    });

    const imageUrl = response.data[0].url;
    console.log('🔗 Image URL:', imageUrl);

    // Download and save image
    await downloadImage(imageUrl, outputPath);

    console.log(`✅ Image successfully generated and saved to: ${outputPath}`);

    // Get file stats
    const stats = await fs.stat(outputPath);
    console.log(`📊 File size: ${(stats.size / 1024).toFixed(1)} KB`);

    return outputPath;

  } catch (error) {
    console.error('❌ Error generating image:', error.message);
    throw error;
  }
}

/**
 * Generate multiple images in batch
 */
async function generateBatchImages(imageConfigs) {
  console.log(`📦 Generating ${imageConfigs.length} images in batch...`);

  const results = [];

  for (const config of imageConfigs) {
    try {
      const result = await generateSlideImage(config.topic, config.outputPath, config.prompt);
      results.push({ success: true, ...config, result });

      // Small delay to avoid rate limits
      await new Promise(resolve => setTimeout(resolve, 1000));

    } catch (error) {
      results.push({ success: false, ...config, error: error.message });
      console.error(`❌ Failed to generate image for ${config.topic}:`, error.message);
    }
  }

  console.log('\n📋 Batch generation results:');
  results.forEach((result, index) => {
    if (result.success) {
      console.log(`${index + 1}. ✅ ${result.topic} → ${result.outputPath}`);
    } else {
      console.log(`${index + 1}. ❌ ${result.topic} → ${result.error}`);
    }
  });

  return results;
}

/**
 * Main CLI handler
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('🎨 OpenAI Image Generator for Slidev Presentation');
    console.log('');
    console.log('Usage:');
    console.log('  node scripts/generate-images.js <topic> [output-path]');
    console.log('  node scripts/generate-images.js batch');
    console.log('');
    console.log('Available topics:');
    Object.keys(PROMPTS).forEach(topic => {
      console.log(`  - ${topic}`);
    });
    console.log('');
    console.log('Examples:');
    console.log('  node scripts/generate-images.js ai-concept images/slides/ai-concept.png');
    console.log('  OPENAI_API_KEY=sk-... node scripts/generate-images.js workflow images/workflow.png');
    return;
  }

  const command = args[0];

  if (command === 'batch') {
    // Generate multiple images for the presentation
    const batchConfigs = [
      { topic: 'ai-concept', outputPath: 'images/slides/ai-concept.png' },
      { topic: 'workflow', outputPath: 'images/slides/workflow.png' },
      { topic: 'architecture', outputPath: 'images/slides/architecture.png' },
      { topic: 'ai-assistant', outputPath: 'images/icons/ai-assistant.png' },
      { topic: 'code-editor', outputPath: 'images/icons/code-editor.png' },
      { topic: 'neural-network', outputPath: 'images/icons/neural-network.png' },
      { topic: 'data-flow', outputPath: 'images/diagrams/data-flow.png' }
    ];

    await generateBatchImages(batchConfigs);

  } else {
    // Generate single image
    const topic = command;
    const outputPath = args[1] || `images/generated/${topic}.png`;

    await generateSlideImage(topic, outputPath);
  }
}

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  console.error('💥 Uncaught Exception:', error.message);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('💥 Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Run the script
if (require.main === module) {
  main().catch((error) => {
    console.error('💥 Script failed:', error.message);
    process.exit(1);
  });
}

module.exports = {
  generateSlideImage,
  generateBatchImages,
  PROMPTS
};