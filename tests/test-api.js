const http = require('http');

const API_URL = process.env.API_URL || 'http://php-apache/api.php';
const MAX_RETRIES = 10;
const RETRY_DELAY = 3000;

// Helper function to make HTTP request
function makeRequest(url) {
    return new Promise((resolve, reject) => {
        const req = http.get(url, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                try {
                    const jsonData = JSON.parse(data);
                    resolve({
                        statusCode: res.statusCode,
                        data: jsonData
                    });
                } catch (e) {
                    reject(new Error('Invalid JSON response'));
                }
            });
        });
        
        req.on('error', (error) => {
            reject(error);
        });
        
        req.setTimeout(5000, () => {
            req.destroy();
            reject(new Error('Request timeout'));
        });
    });
}

// Wait for service to be ready
async function waitForService(url, retries = MAX_RETRIES) {
    for (let i = 0; i < retries; i++) {
        try {
            await makeRequest(url);
            console.log(`Service is ready after ${i + 1} attempt(s)`);
            return true;
        } catch (error) {
            console.log(`Attempt ${i + 1}/${retries}: Service not ready yet...`);
            if (i < retries - 1) {
                await new Promise(resolve => setTimeout(resolve, RETRY_DELAY));
            }
        }
    }
    return false;
}

// Test 1: Check if API returns "Hello World"
async function testHelloWorld() {
    console.log('\n=== Test 1: Hello World API Test ===');
    try {
        const response = await makeRequest(API_URL);
        
        if (response.statusCode !== 200) {
            throw new Error(`Expected status code 200, got ${response.statusCode}`);
        }
        
        if (response.data.status !== 'success') {
            throw new Error(`Expected status 'success', got '${response.data.status}'`);
        }
        
        if (response.data.message !== 'Hello World') {
            throw new Error(`Expected message 'Hello World', got '${response.data.message}'`);
        }
        
        console.log('✓ Test 1 PASSED: API returns "Hello World"');
        return true;
    } catch (error) {
        console.error('✗ Test 1 FAILED:', error.message);
        return false;
    }
}

// Test 2: Check API response structure
async function testResponseStructure() {
    console.log('\n=== Test 2: API Response Structure Test ===');
    try {
        const response = await makeRequest(API_URL);
        
        if (!response.data.hasOwnProperty('status')) {
            throw new Error('Response missing "status" field');
        }
        
        if (!response.data.hasOwnProperty('message')) {
            throw new Error('Response missing "message" field');
        }
        
        if (typeof response.data.message !== 'string') {
            throw new Error('Message field is not a string');
        }
        
        console.log('✓ Test 2 PASSED: API response structure is valid');
        return true;
    } catch (error) {
        console.error('✗ Test 2 FAILED:', error.message);
        return false;
    }
}

// Main test runner
async function runTests() {
    console.log('Starting API tests...');
    console.log(`API URL: ${API_URL}`);
    
    // Wait for service to be ready
    console.log('\nWaiting for services to be ready...');
    const serviceReady = await waitForService(API_URL);
    
    if (!serviceReady) {
        console.error('\n✗ Services failed to become ready');
        process.exit(1);
    }
    
    // Run tests
    const test1 = await testHelloWorld();
    const test2 = await testResponseStructure();
    
    // Summary
    console.log('\n=== Test Summary ===');
    console.log(`Test 1 (Hello World): ${test1 ? 'PASSED' : 'FAILED'}`);
    console.log(`Test 2 (Response Structure): ${test2 ? 'PASSED' : 'FAILED'}`);
    
    if (test1 && test2) {
        console.log('\n✓ All tests PASSED');
        process.exit(0);
    } else {
        console.log('\n✗ Some tests FAILED');
        process.exit(1);
    }
}

// Run tests
runTests().catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
});

