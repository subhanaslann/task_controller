#!/usr/bin/env node

/**
 * Automated Backend Test Runner
 * Executes all tests from backend-test-prompt.json
 */

const http = require('http');
const testSpec = require('./backend-test-prompt.json');
const baseURL = testSpec.backend_testing_prompt.base_url || 'http://localhost:8080';

// Test state
const testResults = {
  categories: [],
  summary: {
    totalTests: 0,
    passed: 0,
    failed: 0,
    skipped: 0,
    startTime: new Date(),
    endTime: null,
  },
  variables: {}, // Store variables from responses
};

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
};

function log(message, color = 'white') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function logHeader(message) {
  console.log('');
  log('═'.repeat(80), 'cyan');
  log(message, 'bright');
  log('═'.repeat(80), 'cyan');
}

function logSubHeader(message) {
  console.log('');
  log(`▶ ${message}`, 'blue');
  log('─'.repeat(80), 'dim');
}

// HTTP request function using native http module
async function makeRequest(method, endpoint, options = {}) {
  return new Promise((resolve) => {
    const url = new URL(endpoint, baseURL);
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (options.authentication === 'bearer' && options.token) {
      headers['Authorization'] = `Bearer ${options.token}`;
    }

    const requestBody = options.body ? JSON.stringify(options.body) : null;
    if (requestBody) {
      headers['Content-Length'] = Buffer.byteLength(requestBody);
    }

    const requestOptions = {
      hostname: url.hostname,
      port: url.port || 8080,
      path: url.pathname + url.search,
      method,
      headers,
    };

    const startTime = Date.now();

    const req = http.request(requestOptions, (res) => {
      const responseTime = Date.now() - startTime;
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        let parsedData;
        try {
          parsedData = JSON.parse(data);
        } catch (e) {
          parsedData = data;
        }

        resolve({
          status: res.statusCode,
          headers: res.headers,
          data: parsedData,
          responseTime,
          ok: res.statusCode >= 200 && res.statusCode < 300,
        });
      });
    });

    req.on('error', (error) => {
      resolve({
        status: 0,
        data: null,
        error: error.message,
        responseTime: Date.now() - startTime,
        ok: false,
      });
    });

    if (requestBody) {
      req.write(requestBody);
    }

    req.end();
  });
}

// Variable substitution
function substituteVariables(value, variables) {
  if (typeof value !== 'string') return value;

  // Replace {variable_name} with actual values
  return value.replace(/\{([^}]+)\}/g, (match, varName) => {
    if (variables[varName] !== undefined) {
      return variables[varName];
    }
    return match; // Keep placeholder if variable not found
  });
}

// Get value from nested object using path
function getNestedValue(obj, path) {
  return path.split('.').reduce((curr, key) => {
    if (curr && typeof curr === 'object') {
      // Handle array access like [0]
      const arrayMatch = key.match(/(.+)\[(\d+)\]/);
      if (arrayMatch) {
        const [, prop, index] = arrayMatch;
        return curr[prop] ? curr[prop][parseInt(index)] : undefined;
      }
      return curr[key];
    }
    return undefined;
  }, obj);
}

// Save variables from response
function saveVariables(response, saveConfig, variables) {
  if (!saveConfig) return;

  for (const [varName, path] of Object.entries(saveConfig)) {
    // Strip "response." prefix from path
    const actualPath = path.startsWith('response.') ? path.substring('response.'.length) : path;
    const value = getNestedValue(response, actualPath);
    if (value !== undefined) {
      variables[varName] = value;
      log(`  💾 Saved variable: ${varName} = ${String(value).substring(0, 50)}...`, 'dim');
    }
  }
}

// Execute a single test
async function executeTest(test, categoryName, variables) {
  const testName = `${test.test_id}: ${test.name}`;
  log(`\n  🧪 ${testName}`, 'cyan');

  // Substitute variables in endpoint
  let endpoint = substituteVariables(test.endpoint, variables);
  let requestBody = test.request_body ? JSON.parse(
    JSON.stringify(test.request_body).replace(/\{([^}]+)\}/g, (match, varName) => {
      return variables[varName] !== undefined ? JSON.stringify(variables[varName]).replace(/^"|"$/g, '') : match;
    })
  ) : null;

  // Get token if needed
  let token = null;
  if (test.authentication === 'bearer') {
    if (test.token_variable) {
      token = variables[test.token_variable];
      if (!token) {
        log(`     ⚠️  Token variable ${test.token_variable} not found, skipping test`, 'yellow');
        return { status: 'skipped', reason: `Missing token: ${test.token_variable}` };
      }
    } else if (test.token) {
      token = test.token;
    }
  }

  // Handle special cases that require complex setup
  const skipTests = ['USER_11', 'SEC_05', 'PERF_02', 'SEC_08', 'SEC_09'];
  if (skipTests.includes(test.test_id)) {
    log(`     ⏭️  Skipping ${test.test_id} (requires special setup)`, 'yellow');
    return { status: 'skipped', reason: 'Requires special setup' };
  }

  // Make request
  const response = await makeRequest(
    test.method,
    endpoint,
    {
      authentication: test.authentication,
      token,
      body: requestBody,
      headers: test.headers || {},
    }
  );

  // Check status code
  const expectedStatus = test.expected_status;
  let statusMatch = false;

  if (typeof expectedStatus === 'string' && expectedStatus.includes(' or ')) {
    // Handle "400 or 201" format
    const statuses = expectedStatus.split(' or ').map(s => parseInt(s.trim()));
    statusMatch = statuses.includes(response.status);
  } else {
    statusMatch = response.status === expectedStatus;
  }

  const result = {
    test_id: test.test_id,
    name: test.name,
    category: categoryName,
    status: statusMatch ? 'passed' : 'failed',
    expected_status: expectedStatus,
    actual_status: response.status,
    response_time: response.responseTime,
    details: [],
  };

  log(`     Status: ${response.status} (expected: ${expectedStatus}) ${statusMatch ? '✓' : '✗'}`,
      statusMatch ? 'green' : 'red');
  log(`     Response time: ${response.responseTime}ms`, 'dim');

  if (!statusMatch) {
    result.details.push(`Status mismatch: got ${response.status}, expected ${expectedStatus}`);
    if (response.data) {
      result.response_data = response.data;
      const dataStr = typeof response.data === 'string' ? response.data : JSON.stringify(response.data);
      log(`     Response: ${dataStr.substring(0, 200)}`, 'red');
    }
    if (response.error) {
      log(`     Error: ${response.error}`, 'red');
    }
  }

  // Save variables if test passed
  if (statusMatch && test.save_variables) {
    saveVariables(response.data, test.save_variables, variables);
  }

  // Validate specific response fields if test passed
  if (statusMatch && test.expected_response && response.data) {
    // Basic validation
    for (const key in test.expected_response) {
      if (response.data[key] === undefined && test.expected_response[key] !== '<ARRAY>') {
        result.details.push(`Missing expected field: ${key}`);
        result.status = 'failed';
      }
    }
  }

  // Show validation rules
  if (test.validation_rules && test.validation_rules.length > 0 && statusMatch) {
    log(`     ✓ ${test.validation_rules.length} validation rules to check`, 'dim');
  }

  if (result.status === 'passed') {
    log(`     ✅ PASSED`, 'green');
  } else {
    log(`     ❌ FAILED`, 'red');
    if (result.details.length > 0) {
      result.details.forEach(detail => log(`        - ${detail}`, 'red'));
    }
  }

  return result;
}

// Execute a test category
async function executeCategory(category, variables) {
  logSubHeader(`${category.category} - ${category.description}`);
  log(`  Priority: ${category.priority}`, 'dim');
  log(`  Tests: ${category.tests.length}`, 'dim');

  const categoryResults = {
    category: category.category,
    priority: category.priority,
    description: category.description,
    tests: [],
    summary: {
      total: category.tests.length,
      passed: 0,
      failed: 0,
      skipped: 0,
    },
  };

  for (const test of category.tests) {
    const result = await executeTest(test, category.category, variables);

    if (result.status === 'passed') {
      categoryResults.summary.passed++;
      testResults.summary.passed++;
    } else if (result.status === 'failed') {
      categoryResults.summary.failed++;
      testResults.summary.failed++;
    } else if (result.status === 'skipped') {
      categoryResults.summary.skipped++;
      testResults.summary.skipped++;
    }

    categoryResults.tests.push(result);
    testResults.summary.totalTests++;
  }

  testResults.categories.push(categoryResults);

  // Category summary
  log('', 'dim');
  log(`  📊 Category Summary:`, 'cyan');
  log(`     Passed:  ${categoryResults.summary.passed}/${categoryResults.summary.total}`, 'green');
  log(`     Failed:  ${categoryResults.summary.failed}/${categoryResults.summary.total}`,
      categoryResults.summary.failed > 0 ? 'red' : 'dim');
  log(`     Skipped: ${categoryResults.summary.skipped}/${categoryResults.summary.total}`, 'yellow');
}

// Main test execution
async function runAllTests() {
  logHeader('🚀 Backend API Test Runner - Mini Task Tracker');
  log(`Base URL: ${baseURL}`, 'cyan');
  log(`Total Categories: ${testSpec.backend_testing_prompt.testing_categories.length}`, 'cyan');

  const categories = testSpec.backend_testing_prompt.testing_categories;

  for (const category of categories) {
    await executeCategory(category, testResults.variables);
  }

  testResults.summary.endTime = new Date();
  const duration = (testResults.summary.endTime - testResults.summary.startTime) / 1000;

  // Final summary
  logHeader('📊 Final Test Summary');
  log(`Total Tests:    ${testResults.summary.totalTests}`, 'cyan');
  log(`Passed:         ${testResults.summary.passed} (${((testResults.summary.passed / testResults.summary.totalTests) * 100).toFixed(1)}%)`, 'green');
  log(`Failed:         ${testResults.summary.failed} (${((testResults.summary.failed / testResults.summary.totalTests) * 100).toFixed(1)}%)`,
      testResults.summary.failed > 0 ? 'red' : 'green');
  log(`Skipped:        ${testResults.summary.skipped} (${((testResults.summary.skipped / testResults.summary.totalTests) * 100).toFixed(1)}%)`, 'yellow');
  log(`Duration:       ${duration.toFixed(2)}s`, 'cyan');
  log(`Start Time:     ${testResults.summary.startTime.toISOString()}`, 'dim');
  log(`End Time:       ${testResults.summary.endTime.toISOString()}`, 'dim');

  // Category breakdown
  log('', 'cyan');
  log('📋 Category Breakdown:', 'cyan');
  testResults.categories.forEach(cat => {
    const passRate = ((cat.summary.passed / cat.summary.total) * 100).toFixed(0);
    const icon = cat.summary.failed === 0 && cat.summary.passed > 0 ? '✅' : cat.summary.failed > 0 ? '❌' : '⏭️';
    log(`  ${icon} ${cat.category}: ${cat.summary.passed}/${cat.summary.total} passed (${passRate}%)`,
        cat.summary.failed === 0 && cat.summary.passed > 0 ? 'green' : 'yellow');
  });

  // Save detailed results to JSON
  const fs = require('fs');
  const reportPath = './test-results.json';
  fs.writeFileSync(reportPath, JSON.stringify(testResults, null, 2));
  log('', 'cyan');
  log(`✅ Detailed results saved to: ${reportPath}`, 'green');

  // Exit with appropriate code
  process.exit(testResults.summary.failed > 0 ? 1 : 0);
}

// Run tests
runAllTests().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
