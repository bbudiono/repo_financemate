#!/usr/bin/env node

/*
 * Comprehensive AG-UI Integration Test Suite
 * Tests backend-frontend integration, WebSocket communication, and API endpoints
 */

import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { spawn } from 'child_process';
import fetch from 'node-fetch';
import { io } from 'socket.io-client';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

class AGUIIntegrationTest {
  constructor() {
    this.baseUrl = 'http://localhost:3001';
    this.wsUrl = 'ws://localhost:3001';
    this.testResults = [];
  }

  log(message, type = 'info') {
    const timestamp = new Date().toISOString();
    const prefix = type === 'error' ? '❌' : type === 'success' ? '✅' : '📝';
    console.log(`[${timestamp}] ${prefix} ${message}`);
  }

  async delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async testBackendHealth() {
    this.log('Testing backend health endpoint...');
    try {
      const response = await fetch(`${this.baseUrl}/api/health`, {
        timeout: 5000
      });
      
      if (response.status === 200) {
        this.log('Backend health check passed', 'success');
        this.testResults.push({ test: 'Backend Health', status: 'PASS' });
        return true;
      } else {
        this.log(`Backend health check failed: ${response.status}`, 'error');
        this.testResults.push({ test: 'Backend Health', status: 'FAIL', error: `Status ${response.status}` });
        return false;
      }
    } catch (error) {
      this.log(`Backend health check error: ${error.message}`, 'error');
      this.testResults.push({ test: 'Backend Health', status: 'FAIL', error: error.message });
      return false;
    }
  }

  async testAgentEndpoints() {
    this.log('Testing agent coordination endpoints...');
    const tests = [
      { endpoint: '/api/agents/status', method: 'GET' },
      { endpoint: '/api/agents/coordinate', method: 'POST', body: { 
        task_description: 'Test task coordination',
        userTier: 'pro' 
      }}
    ];

    let allPassed = true;

    for (const test of tests) {
      try {
        const options = {
          method: test.method,
          headers: {
            'Content-Type': 'application/json',
            'user-tier': 'pro'
          },
          timeout: 10000
        };

        if (test.body) {
          options.body = JSON.stringify(test.body);
        }

        const response = await fetch(`${this.baseUrl}${test.endpoint}`, options);
        
        if (response.status >= 200 && response.status < 300) {
          this.log(`${test.method} ${test.endpoint} passed`, 'success');
          this.testResults.push({ 
            test: `${test.method} ${test.endpoint}`, 
            status: 'PASS' 
          });
        } else {
          this.log(`${test.method} ${test.endpoint} failed: ${response.status}`, 'error');
          this.testResults.push({ 
            test: `${test.method} ${test.endpoint}`, 
            status: 'FAIL', 
            error: `Status ${response.status}` 
          });
          allPassed = false;
        }
      } catch (error) {
        this.log(`${test.method} ${test.endpoint} error: ${error.message}`, 'error');
        this.testResults.push({ 
          test: `${test.method} ${test.endpoint}`, 
          status: 'FAIL', 
          error: error.message 
        });
        allPassed = false;
      }
    }

    return allPassed;
  }

  async testWebSocketConnection() {
    this.log('Testing WebSocket connection...');
    
    return new Promise((resolve) => {
      const socket = io(this.baseUrl, {
        transports: ['websocket'],
        timeout: 10000
      });

      let resolved = false;

      socket.on('connect', () => {
        if (!resolved) {
          this.log('WebSocket connection successful', 'success');
          this.testResults.push({ test: 'WebSocket Connection', status: 'PASS' });
          socket.disconnect();
          resolved = true;
          resolve(true);
        }
      });

      socket.on('connect_error', (error) => {
        if (!resolved) {
          this.log(`WebSocket connection failed: ${error.message}`, 'error');
          this.testResults.push({ test: 'WebSocket Connection', status: 'FAIL', error: error.message });
          resolved = true;
          resolve(false);
        }
      });

      // Timeout after 10 seconds
      setTimeout(() => {
        if (!resolved) {
          this.log('WebSocket connection timeout', 'error');
          this.testResults.push({ test: 'WebSocket Connection', status: 'FAIL', error: 'Timeout' });
          socket.disconnect();
          resolved = true;
          resolve(false);
        }
      }, 10000);
    });
  }

  async testHardwareMetricsEndpoint() {
    this.log('Testing hardware metrics endpoint...');
    try {
      const response = await fetch(`${this.baseUrl}/api/hardware/metrics`, {
        headers: { 'user-tier': 'pro' },
        timeout: 5000
      });
      
      if (response.status === 200) {
        const data = await response.json();
        if (data && typeof data === 'object') {
          this.log('Hardware metrics endpoint passed', 'success');
          this.testResults.push({ test: 'Hardware Metrics', status: 'PASS' });
          return true;
        }
      }
      
      this.log(`Hardware metrics endpoint failed: ${response.status}`, 'error');
      this.testResults.push({ test: 'Hardware Metrics', status: 'FAIL', error: `Status ${response.status}` });
      return false;
    } catch (error) {
      this.log(`Hardware metrics error: ${error.message}`, 'error');
      this.testResults.push({ test: 'Hardware Metrics', status: 'FAIL', error: error.message });
      return false;
    }
  }

  async testWorkflowEndpoints() {
    this.log('Testing workflow management endpoints...');
    const tests = [
      { 
        endpoint: '/api/workflows/create', 
        method: 'POST', 
        body: { 
          name: 'Test Workflow',
          description: 'Integration test workflow',
          userTier: 'pro',
          agentTypes: ['research', 'technical']
        }
      },
      { endpoint: '/api/workflows/list', method: 'GET' }
    ];

    let allPassed = true;

    for (const test of tests) {
      try {
        const options = {
          method: test.method,
          headers: {
            'Content-Type': 'application/json',
            'user-tier': 'pro'
          },
          timeout: 10000
        };

        if (test.body) {
          options.body = JSON.stringify(test.body);
        }

        const response = await fetch(`${this.baseUrl}${test.endpoint}`, options);
        
        if (response.status >= 200 && response.status < 300) {
          this.log(`${test.method} ${test.endpoint} passed`, 'success');
          this.testResults.push({ 
            test: `Workflow ${test.method} ${test.endpoint}`, 
            status: 'PASS' 
          });
        } else {
          this.log(`${test.method} ${test.endpoint} failed: ${response.status}`, 'error');
          this.testResults.push({ 
            test: `Workflow ${test.method} ${test.endpoint}`, 
            status: 'FAIL', 
            error: `Status ${response.status}` 
          });
          allPassed = false;
        }
      } catch (error) {
        this.log(`${test.method} ${test.endpoint} error: ${error.message}`, 'error');
        this.testResults.push({ 
          test: `Workflow ${test.method} ${test.endpoint}`, 
          status: 'FAIL', 
          error: error.message 
        });
        allPassed = false;
      }
    }

    return allPassed;
  }

  async testTierBasedAccess() {
    this.log('Testing tier-based access control...');
    
    const tierTests = [
      { tier: 'free', expectFail: false },
      { tier: 'pro', expectFail: false },
      { tier: 'enterprise', expectFail: false },
      { tier: 'invalid', expectFail: true }
    ];

    let allPassed = true;

    for (const tierTest of tierTests) {
      try {
        const response = await fetch(`${this.baseUrl}/api/agents/coordinate`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'user-tier': tierTest.tier
          },
          body: JSON.stringify({
            task_description: 'Tier access test',
            userTier: tierTest.tier
          }),
          timeout: 5000
        });

        const success = response.status >= 200 && response.status < 300;
        const testPassed = tierTest.expectFail ? !success : success;

        if (testPassed) {
          this.log(`Tier ${tierTest.tier} access control passed`, 'success');
          this.testResults.push({ 
            test: `Tier Access ${tierTest.tier}`, 
            status: 'PASS' 
          });
        } else {
          this.log(`Tier ${tierTest.tier} access control failed`, 'error');
          this.testResults.push({ 
            test: `Tier Access ${tierTest.tier}`, 
            status: 'FAIL', 
            error: `Expected ${tierTest.expectFail ? 'failure' : 'success'}, got ${success ? 'success' : 'failure'}` 
          });
          allPassed = false;
        }
      } catch (error) {
        this.log(`Tier ${tierTest.tier} test error: ${error.message}`, 'error');
        this.testResults.push({ 
          test: `Tier Access ${tierTest.tier}`, 
          status: 'FAIL', 
          error: error.message 
        });
        allPassed = false;
      }
    }

    return allPassed;
  }

  generateReport() {
    this.log('\n🔍 INTEGRATION TEST REPORT');
    this.log('================================');
    
    const passCount = this.testResults.filter(r => r.status === 'PASS').length;
    const failCount = this.testResults.filter(r => r.status === 'FAIL').length;
    const totalCount = this.testResults.length;
    
    this.log(`Total Tests: ${totalCount}`);
    this.log(`Passed: ${passCount}`, 'success');
    this.log(`Failed: ${failCount}`, failCount > 0 ? 'error' : 'info');
    this.log(`Success Rate: ${((passCount / totalCount) * 100).toFixed(1)}%`);
    
    this.log('\nDetailed Results:');
    this.testResults.forEach(result => {
      const status = result.status === 'PASS' ? '✅' : '❌';
      this.log(`${status} ${result.test}${result.error ? ` (${result.error})` : ''}`);
    });

    this.log('\n🎯 INTEGRATION STATUS');
    this.log('====================');
    if (failCount === 0) {
      this.log('🚀 ALL SYSTEMS OPERATIONAL - Ready for production deployment!', 'success');
    } else if (failCount <= 2) {
      this.log('⚠️  Minor issues detected - System mostly functional', 'error');
    } else {
      this.log('🚨 Major issues detected - Requires investigation', 'error');
    }
  }

  async runAllTests() {
    this.log('🚀 Starting AG-UI Integration Test Suite...\n');
    
    const tests = [
      () => this.testBackendHealth(),
      () => this.testAgentEndpoints(),
      () => this.testWebSocketConnection(),
      () => this.testHardwareMetricsEndpoint(),
      () => this.testWorkflowEndpoints(),
      () => this.testTierBasedAccess()
    ];

    for (const test of tests) {
      await test();
      await this.delay(1000); // Small delay between tests
    }

    this.generateReport();
    
    const failCount = this.testResults.filter(r => r.status === 'FAIL').length;
    process.exit(failCount > 0 ? 1 : 0);
  }
}

// Run tests if this script is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const tester = new AGUIIntegrationTest();
  tester.runAllTests().catch(error => {
    console.error('Test suite failed:', error);
    process.exit(1);
  });
}

export default AGUIIntegrationTest;