const axios = require('axios');

const PHP_URL = 'http://php:80';
const MAX_RETRIES = 10;
const RETRY_DELAY = 5000;
const INITIAL_WAIT = 10000;

let passedTests = 0;
let failedTests = 0;

// Helper function to wait
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Helper function to retry requests
async function retryRequest(url, retries = MAX_RETRIES) {
    for (let i = 0; i < retries; i++) {
        try {
            const response = await axios.get(url, { timeout: 10000 });
            return response;
        } catch (error) {
            console.log(`  Connection attempt ${i + 1}/${retries} failed: ${error.message}`);
            if (i < retries - 1) {
                console.log(`  Waiting ${RETRY_DELAY/1000} seconds before retry...`);
                await sleep(RETRY_DELAY);
            } else {
                throw error;
            }
        }
    }
}

async function test1_CheckHomePage() {
    console.log('\n--- Test 1: Check Home Page ---');
    try {
        const response = await retryRequest(`${PHP_URL}/index.php`);
        if (response.status === 200 && response.data.includes('DevOps CI/CD Project')) {
            console.log('✓ Test 1 PASSED: Home page is accessible and contains expected content');
            passedTests++;
            return true;
        } else {
            console.log('✗ Test 1 FAILED: Home page does not contain expected content');
            console.log('  Status:', response.status);
            failedTests++;
            return false;
        }
    } catch (error) {
        console.log('✗ Test 1 FAILED: ' + error.message);
        failedTests++;
        return false;
    }
}

async function test2_CheckAPIHelloWorld() {
    console.log('\n--- Test 2: Check API Returns Hello World ---');
    
    // Extra wait before API test to ensure MySQL connection is ready
    console.log('  Waiting for database connection to be ready...');
    await sleep(5000);
    
    try {
        const response = await retryRequest(`${PHP_URL}/api.php`);
        const data = response.data;
        
        if (data.status === 'success' && data.message === 'Hello World3283289832') {
            console.log('✓ Test 2 PASSED: API returns "Hello World" correctly');
            passedTests++;
            return true;
        } else {
            console.log('✗ Test 2 FAILED: API did not return expected "Hello World"');
            console.log('  Received:', JSON.stringify(data));
            failedTests++;
            return false;
        }
    } catch (error) {
        console.log('✗ Test 2 FAILED: ' + error.message);
        failedTests++;
        return false;
    }
}

async function runTests() {
    console.log('========================================');
    console.log('    DevOps CI/CD Unit Tests');
    console.log('    Author: Ali Nasser');
    console.log('========================================');
    
    // Initial wait for all services to be fully ready
    console.log(`\nInitial wait: ${INITIAL_WAIT/1000} seconds for services to stabilize...`);
    await sleep(INITIAL_WAIT);
    console.log('Starting tests...\n');
    
    await test1_CheckHomePage();
    
    // Wait between tests
    console.log('\nWaiting 3 seconds before next test...');
    await sleep(3000);
    
    await test2_CheckAPIHelloWorld();
    
    console.log('\n========================================');
    console.log(`    Results: ${passedTests} passed, ${failedTests} failed`);
    console.log('========================================\n');
    
    if (failedTests > 0) {
        console.log('TESTS FAILED - Build should not proceed');
        process.exit(1);
    } else {
        console.log('ALL TESTS PASSED - Build can proceed');
        process.exit(0);
    }
}

runTests();
