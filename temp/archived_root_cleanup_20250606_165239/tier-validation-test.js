/*
* Purpose: Comprehensive tier-based access control validation test
* Tests all components to ensure proper access restriction and feature gating
*/

import fetch from 'node-fetch';

const BASE_URL = 'http://localhost:3001';

const tierTests = [
  {
    tier: 'free',
    shouldPass: [
      { endpoint: '/api/agents/status', method: 'GET' },
      { endpoint: '/api/hardware/metrics', method: 'GET' }
    ],
    shouldFail: [
      { endpoint: '/api/agents/video/generate', method: 'POST', expectedError: 'Enterprise tier' },
      { endpoint: '/api/hardware/optimize', method: 'POST', expectedError: 'Pro or Enterprise tier' },
      { endpoint: '/api/admin/metrics/system', method: 'GET', expectedError: 'Enterprise tier' },
      { endpoint: '/api/video/projects', method: 'GET', expectedError: 'Enterprise tier' }
    ]
  },
  {
    tier: 'pro', 
    shouldPass: [
      { endpoint: '/api/agents/status', method: 'GET' },
      { endpoint: '/api/hardware/metrics', method: 'GET' },
      { endpoint: '/api/hardware/optimize', method: 'POST' }
    ],
    shouldFail: [
      { endpoint: '/api/agents/video/generate', method: 'POST', expectedError: 'Enterprise tier' },
      { endpoint: '/api/admin/metrics/system', method: 'GET', expectedError: 'Enterprise tier' },
      { endpoint: '/api/video/projects', method: 'GET', expectedError: 'Enterprise tier' }
    ]
  },
  {
    tier: 'enterprise',
    shouldPass: [
      { endpoint: '/api/agents/status', method: 'GET' },
      { endpoint: '/api/hardware/metrics', method: 'GET' },
      { endpoint: '/api/hardware/optimize', method: 'POST' },
      { endpoint: '/api/agents/video/generate', method: 'POST' },
      { endpoint: '/api/admin/metrics/system', method: 'GET' },
      { endpoint: '/api/video/projects', method: 'GET' }
    ],
    shouldFail: []
  }
];

async function testTierAccess(tier, test, shouldPass) {
  try {
    const options = {
      method: test.method,
      headers: {
        'Content-Type': 'application/json',
        'user-tier': tier
      }
    };

    if (test.method === 'POST') {
      options.body = JSON.stringify({
        project_name: 'Test Project',
        description: 'Test description',
        optimization_type: 'test'
      });
    }

    const response = await fetch(`${BASE_URL}${test.endpoint}`, options);

    if (shouldPass) {
      if (response.status >= 200 && response.status < 300) {
        return { success: true, message: `✅ ${tier.toUpperCase()} - ${test.endpoint} - Access granted as expected` };
      } else {
        const error = await response.text();
        return { success: false, message: `❌ ${tier.toUpperCase()} - ${test.endpoint} - Should pass but failed: ${error}` };
      }
    } else {
      if (response.status === 403) {
        const error = await response.json();
        if (error.error && error.error.includes(test.expectedError)) {
          return { success: true, message: `✅ ${tier.toUpperCase()} - ${test.endpoint} - Correctly blocked: ${error.error}` };
        } else {
          return { success: false, message: `❌ ${tier.toUpperCase()} - ${test.endpoint} - Wrong error message: ${error.error}` };
        }
      } else {
        return { success: false, message: `❌ ${tier.toUpperCase()} - ${test.endpoint} - Should be blocked but got status: ${response.status}` };
      }
    }
  } catch (error) {
    return { success: false, message: `❌ ${tier.toUpperCase()} - ${test.endpoint} - Network error: ${error.message}` };
  }
}

async function runTierValidationTests() {
  console.log('🔐 Starting Tier-Based Access Control Validation...\n');

  let totalTests = 0;
  let passedTests = 0;
  const results = [];

  for (const tierTest of tierTests) {
    console.log(`📋 Testing ${tierTest.tier.toUpperCase()} tier access controls...`);

    // Test endpoints that should pass
    for (const test of tierTest.shouldPass) {
      totalTests++;
      const result = await testTierAccess(tierTest.tier, test, true);
      results.push(result);
      console.log(result.message);
      if (result.success) passedTests++;
    }

    // Test endpoints that should fail
    for (const test of tierTest.shouldFail) {
      totalTests++;
      const result = await testTierAccess(tierTest.tier, test, false);
      results.push(result);
      console.log(result.message);
      if (result.success) passedTests++;
    }

    console.log('');
  }

  console.log('📊 TIER VALIDATION TEST RESULTS');
  console.log('==================================================');
  console.log(`✅ Passed: ${passedTests}`);
  console.log(`❌ Failed: ${totalTests - passedTests}`);
  console.log(`📈 Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`);
  console.log('');

  console.log('🎯 TIER ACCESS CONTROL SUMMARY:');
  console.log('🆓 Free Tier: Basic access only, blocked from premium features');
  console.log('💎 Pro Tier: Advanced features enabled, video generation blocked');
  console.log('🏢 Enterprise Tier: Full access to all features and admin tools');
  console.log('');

  if (passedTests === totalTests) {
    console.log('🎉 OVERALL STATUS: TIER-BASED ACCESS CONTROLS WORKING PERFECTLY');
    console.log('✨ All tier restrictions properly enforced!');
    console.log('✨ Feature gating implemented correctly!');
  } else {
    console.log('⚠️  OVERALL STATUS: SOME TIER ACCESS CONTROL ISSUES DETECTED');
    console.log('🔧 Review failed tests above for details');
  }

  return { totalTests, passedTests, successRate: (passedTests / totalTests) * 100 };
}

// Run the tests
runTierValidationTests()
  .then(results => {
    process.exit(results.successRate === 100 ? 0 : 1);
  })
  .catch(error => {
    console.error('Test execution failed:', error);
    process.exit(1);
  });

export { runTierValidationTests };