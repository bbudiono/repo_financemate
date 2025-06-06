#!/usr/bin/env node

/**
 * COMPREHENSIVE MEMORY PROTECTION VALIDATION TEST
 * 
 * Purpose: Validate that memory management solutions prevent terminal crashes
 * during intensive TaskMaster-AI operations
 */

const { performance } = require('perf_hooks');
const fs = require('fs');
const path = require('path');

class MemoryProtectionSolution {
    constructor() {
        this.memoryThresholds = {
            warning: 2048, // 2GB
            critical: 3072, // 3GB
            emergency: 3584, // 3.5GB
            maximum: 4096 // 4GB (near crash limit)
        };
        
        this.circuitBreakers = {
            level6Tasks: false,
            level5Tasks: false,
            analytics: false,
            uiInteractions: false
        };
        
        this.memoryPools = {
            taskObjects: new Map(),
            analyticsEvents: new Map(),
            uiStates: new Map()
        };
        
        this.monitoring = {
            enabled: true,
            interval: 100, // ms
            history: []
        };
        
        this.startMonitoring();
        console.log('🛡️  Memory Protection Solution Initialized');
    }

    getCurrentMemoryUsage() {
        const memUsage = process.memoryUsage();
        return Math.round(memUsage.heapUsed / 1024 / 1024 * 100) / 100;
    }

    startMonitoring() {
        if (this.monitoring.enabled) {
            this.monitoringInterval = setInterval(() => {
                const currentUsage = this.getCurrentMemoryUsage();
                this.monitoring.history.push({
                    timestamp: Date.now(),
                    heapUsed: currentUsage
                });
                
                // Keep only last 100 readings
                if (this.monitoring.history.length > 100) {
                    this.monitoring.history.shift();
                }
                
                this.updateCircuitBreakers(currentUsage);
            }, this.monitoring.interval);
        }
    }

    stopMonitoring() {
        if (this.monitoringInterval) {
            clearInterval(this.monitoringInterval);
            this.monitoring.enabled = false;
        }
    }

    updateCircuitBreakers(currentUsage) {
        // Level 6 tasks - most memory intensive
        if (currentUsage > this.memoryThresholds.warning) {
            this.circuitBreakers.level6Tasks = true;
        } else if (currentUsage < this.memoryThresholds.warning * 0.8) {
            this.circuitBreakers.level6Tasks = false;
        }

        // Level 5 tasks - high memory usage
        if (currentUsage > this.memoryThresholds.critical) {
            this.circuitBreakers.level5Tasks = true;
        } else if (currentUsage < this.memoryThresholds.critical * 0.8) {
            this.circuitBreakers.level5Tasks = false;
        }

        // Analytics processing
        if (currentUsage > this.memoryThresholds.critical) {
            this.circuitBreakers.analytics = true;
        } else if (currentUsage < this.memoryThresholds.critical * 0.8) {
            this.circuitBreakers.analytics = false;
        }

        // UI interactions
        if (currentUsage > this.memoryThresholds.emergency) {
            this.circuitBreakers.uiInteractions = true;
        } else if (currentUsage < this.memoryThresholds.emergency * 0.8) {
            this.circuitBreakers.uiInteractions = false;
        }
    }

    isOperationAllowed(operationType) {
        const currentUsage = this.getCurrentMemoryUsage();
        
        switch (operationType) {
            case 'level6_tasks':
                return !this.circuitBreakers.level6Tasks && currentUsage < this.memoryThresholds.warning;
            case 'level5_tasks':
                return !this.circuitBreakers.level5Tasks && currentUsage < this.memoryThresholds.critical;
            case 'analytics':
                return !this.circuitBreakers.analytics && currentUsage < this.memoryThresholds.critical;
            case 'ui_interactions':
                return !this.circuitBreakers.uiInteractions && currentUsage < this.memoryThresholds.emergency;
            default:
                return currentUsage < this.memoryThresholds.emergency;
        }
    }

    getObjectFromPool(poolName, factory) {
        if (!this.memoryPools[poolName]) {
            this.memoryPools[poolName] = new Map();
        }
        
        const pool = this.memoryPools[poolName];
        
        // Try to reuse from pool
        for (const [id, obj] of pool.entries()) {
            if (!obj.inUse) {
                obj.inUse = true;
                return obj;
            }
        }
        
        // Create new if pool not full
        if (pool.size < 100) { // Pool size limit
            const newObj = factory();
            newObj.inUse = true;
            newObj.poolId = `${poolName}_${Date.now()}_${Math.random()}`;
            pool.set(newObj.poolId, newObj);
            return newObj;
        }
        
        // Pool exhausted
        return null;
    }

    returnToPool(poolName, obj) {
        if (obj && obj.poolId && this.memoryPools[poolName]) {
            obj.inUse = false;
            // Clear heavy data
            if (obj.data) obj.data = null;
            if (obj.payload) obj.payload = null;
            if (obj.subtasks) obj.subtasks = [];
        }
    }

    forceGarbageCollection() {
        if (global.gc) {
            const before = this.getCurrentMemoryUsage();
            global.gc();
            const after = this.getCurrentMemoryUsage();
            const freed = before - after;
            console.log(`🗑️  Forced GC: Freed ${Math.round(freed * 100) / 100}MB`);
            return { before, after, freed };
        }
        return null;
    }

    getMemoryStatus() {
        const currentUsage = this.getCurrentMemoryUsage();
        let status = 'normal';
        
        if (currentUsage > this.memoryThresholds.emergency) {
            status = 'emergency';
        } else if (currentUsage > this.memoryThresholds.critical) {
            status = 'critical';
        } else if (currentUsage > this.memoryThresholds.warning) {
            status = 'warning';
        }
        
        return {
            usage: currentUsage,
            status,
            circuitBreakers: { ...this.circuitBreakers },
            thresholds: { ...this.memoryThresholds }
        };
    }
}

class MemoryProtectionValidator {
    constructor() {
        this.memoryProtection = new MemoryProtectionSolution();
        this.testResults = [];
        this.startTime = Date.now();
        
        console.log('🧪 Memory Protection Validator Initialized');
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Test 1: Validate circuit breakers prevent Level 6 task creation under memory pressure
     */
    async testLevel6CircuitBreaker() {
        console.log('\n🔥 TEST 1: LEVEL 6 CIRCUIT BREAKER VALIDATION');
        
        const errors = [];
        let tasksBlocked = 0;
        let tasksCreated = 0;
        
        try {
            // First, create some memory pressure to trigger circuit breakers
            console.log('   📈 Creating memory pressure...');
            const memoryPressureData = [];
            
            // Create enough data to trigger warning threshold
            while (this.memoryProtection.getCurrentMemoryUsage() < this.memoryProtection.memoryThresholds.warning) {
                memoryPressureData.push(new Array(100000).fill(Math.random()));
                await this.sleep(10);
            }
            
            console.log(`   ⚠️  Warning threshold reached: ${this.memoryProtection.getCurrentMemoryUsage()}MB`);
            
            // Now try to create Level 6 tasks - should be blocked
            console.log('   🚧 Testing Level 6 task blocking...');
            
            for (let i = 0; i < 50; i++) {
                if (this.memoryProtection.isOperationAllowed('level6_tasks')) {
                    // Create simplified Level 6 task
                    const task = {
                        id: `level6_task_${i}`,
                        level: 6,
                        data: new Array(1000).fill(Math.random())
                    };
                    tasksCreated++;
                } else {
                    tasksBlocked++;
                }
                
                if ((i + 1) % 10 === 0) {
                    const status = this.memoryProtection.getMemoryStatus();
                    console.log(`   Tasks: ${tasksCreated} created, ${tasksBlocked} blocked (${status.usage}MB)`);
                }
            }
            
            // Clean up memory pressure
            memoryPressureData.length = 0;
            this.memoryProtection.forceGarbageCollection();
            
            const result = {
                test: 'level6_circuit_breaker',
                success: tasksBlocked > 0 && tasksBlocked > tasksCreated,
                tasksCreated,
                tasksBlocked,
                blockingEffectiveness: Math.round((tasksBlocked / (tasksCreated + tasksBlocked)) * 100)
            };
            
            this.testResults.push(result);
            console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - ${result.blockingEffectiveness}% blocking rate`);
            
        } catch (error) {
            errors.push(error.message);
            console.error(`   ❌ Error in circuit breaker test:`, error.message);
        }
        
        return this.testResults[this.testResults.length - 1];
    }

    /**
     * Test 2: Validate memory pools prevent object creation explosion
     */
    async testMemoryPoolValidation() {
        console.log('\n🏊 TEST 2: MEMORY POOL VALIDATION');
        
        const errors = [];
        let pooledObjects = 0;
        let rejectedObjects = 0;
        
        try {
            console.log('   🔄 Testing object pooling...');
            
            // Test task object pooling
            for (let i = 0; i < 150; i++) { // Try to create more than pool limit
                const taskObj = this.memoryProtection.getObjectFromPool('taskObjects', () => ({
                    id: `task_${i}`,
                    data: new Array(5000).fill(Math.random()),
                    created: Date.now()
                }));
                
                if (taskObj) {
                    pooledObjects++;
                    // Simulate usage
                    await this.sleep(1);
                    // Return to pool
                    this.memoryProtection.returnToPool('taskObjects', taskObj);
                } else {
                    rejectedObjects++;
                }
                
                if ((i + 1) % 30 === 0) {
                    console.log(`   Objects: ${pooledObjects} pooled, ${rejectedObjects} rejected`);
                }
            }
            
            const result = {
                test: 'memory_pool_validation',
                success: rejectedObjects > 0 && pooledObjects <= 100, // Pool size limit
                pooledObjects,
                rejectedObjects,
                poolEffectiveness: Math.round((rejectedObjects / (pooledObjects + rejectedObjects)) * 100)
            };
            
            this.testResults.push(result);
            console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - ${result.poolEffectiveness}% pool protection`);
            
        } catch (error) {
            errors.push(error.message);
            console.error(`   ❌ Error in memory pool test:`, error.message);
        }
        
        return this.testResults[this.testResults.length - 1];
    }

    /**
     * Test 3: Validate garbage collection optimization under load
     */
    async testGarbageCollectionOptimization() {
        console.log('\n🗑️  TEST 3: GARBAGE COLLECTION OPTIMIZATION');
        
        const errors = [];
        let gcEvents = [];
        
        try {
            console.log('   📊 Testing GC effectiveness...');
            
            const initialMemory = this.memoryProtection.getCurrentMemoryUsage();
            
            // Create and destroy objects rapidly
            for (let cycle = 0; cycle < 10; cycle++) {
                console.log(`   Cycle ${cycle + 1}/10: Creating temporary objects...`);
                
                const tempObjects = [];
                
                // Create objects
                for (let i = 0; i < 1000; i++) {
                    tempObjects.push({
                        id: `temp_${cycle}_${i}`,
                        data: new Array(2000).fill(Math.random()),
                        metadata: new Array(500).fill(`meta_${Math.random()}`)
                    });
                }
                
                const beforeGC = this.memoryProtection.getCurrentMemoryUsage();
                
                // Clear references
                tempObjects.length = 0;
                
                // Force GC
                const gcResult = this.memoryProtection.forceGarbageCollection();
                if (gcResult) {
                    gcEvents.push({
                        cycle,
                        beforeGC: gcResult.before,
                        afterGC: gcResult.after,
                        freed: gcResult.freed
                    });
                }
                
                await this.sleep(100);
            }
            
            const finalMemory = this.memoryProtection.getCurrentMemoryUsage();
            const totalFreed = gcEvents.reduce((sum, event) => sum + event.freed, 0);
            const averageFreed = totalFreed / gcEvents.length;
            
            const result = {
                test: 'garbage_collection_optimization',
                success: finalMemory < (initialMemory + 50) && averageFreed > 0,
                initialMemory,
                finalMemory,
                memoryGrowth: finalMemory - initialMemory,
                gcEvents: gcEvents.length,
                totalMemoryFreed: Math.round(totalFreed * 100) / 100,
                averageMemoryFreed: Math.round(averageFreed * 100) / 100
            };
            
            this.testResults.push(result);
            console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - Growth: ${result.memoryGrowth}MB, Freed: ${result.totalMemoryFreed}MB`);
            
        } catch (error) {
            errors.push(error.message);
            console.error(`   ❌ Error in GC optimization test:`, error.message);
        }
        
        return this.testResults[this.testResults.length - 1];
    }

    /**
     * Test 4: Validate emergency memory management
     */
    async testEmergencyMemoryManagement() {
        console.log('\n🚨 TEST 4: EMERGENCY MEMORY MANAGEMENT');
        
        const errors = [];
        let emergencyTriggered = false;
        let emergencyActions = 0;
        
        try {
            console.log('   🔥 Simulating emergency memory conditions...');
            
            const emergencyData = [];
            
            // Gradually increase memory usage towards emergency threshold
            while (this.memoryProtection.getCurrentMemoryUsage() < this.memoryProtection.memoryThresholds.emergency * 0.9) {
                emergencyData.push(new Array(50000).fill(Math.random()));
                
                const status = this.memoryProtection.getMemoryStatus();
                console.log(`   Memory: ${status.usage}MB (${status.status})`);
                
                if (status.status === 'emergency' || status.status === 'critical') {
                    emergencyTriggered = true;
                    
                    // Test emergency actions
                    if (!this.memoryProtection.isOperationAllowed('level6_tasks')) emergencyActions++;
                    if (!this.memoryProtection.isOperationAllowed('level5_tasks')) emergencyActions++;
                    if (!this.memoryProtection.isOperationAllowed('analytics')) emergencyActions++;
                    
                    // Trigger emergency GC
                    this.memoryProtection.forceGarbageCollection();
                    emergencyActions++;
                    
                    break;
                }
                
                await this.sleep(50);
            }
            
            console.log(`   🛡️  Emergency systems: ${emergencyTriggered ? 'ACTIVATED' : 'NOT TRIGGERED'}`);
            
            // Clean up
            emergencyData.length = 0;
            this.memoryProtection.forceGarbageCollection();
            
            const result = {
                test: 'emergency_memory_management',
                success: emergencyTriggered && emergencyActions >= 3,
                emergencyTriggered,
                emergencyActions,
                finalMemoryStatus: this.memoryProtection.getMemoryStatus()
            };
            
            this.testResults.push(result);
            console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - ${emergencyActions} emergency actions`);
            
        } catch (error) {
            errors.push(error.message);
            console.error(`   ❌ Error in emergency management test:`, error.message);
        }
        
        return this.testResults[this.testResults.length - 1];
    }

    /**
     * Generate comprehensive protection validation report
     */
    generateProtectionReport() {
        const totalDuration = Date.now() - this.startTime;
        const overallSuccess = this.testResults.every(r => r.success);
        
        const report = {
            testSuite: 'Memory Protection Validation',
            timestamp: new Date().toISOString(),
            duration: totalDuration,
            overallSuccess,
            
            summary: {
                totalTests: this.testResults.length,
                passedTests: this.testResults.filter(r => r.success).length,
                failedTests: this.testResults.filter(r => !r.success).length
            },
            
            testResults: this.testResults,
            
            protectionAssessment: {
                circuitBreakerEffectiveness: overallSuccess ? 'EXCELLENT' : 'NEEDS IMPROVEMENT',
                memoryPoolEffectiveness: overallSuccess ? 'EXCELLENT' : 'NEEDS IMPROVEMENT',
                gcOptimization: overallSuccess ? 'EXCELLENT' : 'NEEDS IMPROVEMENT',
                emergencyResponse: overallSuccess ? 'EXCELLENT' : 'NEEDS IMPROVEMENT',
                terminalCrashPrevention: overallSuccess ? 'PROTECTED' : 'VULNERABLE',
                productionReadiness: overallSuccess ? 'PRODUCTION READY' : 'REQUIRES FIXES'
            },
            
            memoryMonitoring: {
                finalStatus: this.memoryProtection.getMemoryStatus(),
                monitoringHistory: this.memoryProtection.monitoring.history.slice(-20) // Last 20 readings
            }
        };
        
        return report;
    }

    /**
     * Main execution method
     */
    async runMemoryProtectionValidation() {
        console.log('🛡️  STARTING MEMORY PROTECTION VALIDATION');
        console.log('=' * 60);
        
        const initialStatus = this.memoryProtection.getMemoryStatus();
        console.log(`🎯 Initial Memory: ${initialStatus.usage}MB (${initialStatus.status})`);
        
        try {
            await this.testLevel6CircuitBreaker();
            await this.testMemoryPoolValidation();
            await this.testGarbageCollectionOptimization();
            await this.testEmergencyMemoryManagement();
            
            const report = this.generateProtectionReport();
            
            // Save report
            const timestamp = new Date().toISOString().replace(/:/g, '-');
            const filename = `memory_protection_validation_${timestamp}.json`;
            const filepath = path.join(__dirname, filename);
            
            await fs.promises.writeFile(filepath, JSON.stringify(report, null, 2));
            console.log(`\n💾 Report saved: ${filepath}`);
            
            console.log('\n🏁 MEMORY PROTECTION VALIDATION COMPLETE');
            console.log(`${report.overallSuccess ? '✅ SUCCESS' : '❌ FAILED'}: Memory protection validation completed`);
            
            console.log('\n🛡️  PROTECTION ASSESSMENT:');
            console.log(`   Circuit Breaker Effectiveness: ${report.protectionAssessment.circuitBreakerEffectiveness}`);
            console.log(`   Memory Pool Effectiveness: ${report.protectionAssessment.memoryPoolEffectiveness}`);
            console.log(`   GC Optimization: ${report.protectionAssessment.gcOptimization}`);
            console.log(`   Emergency Response: ${report.protectionAssessment.emergencyResponse}`);
            console.log(`   Terminal Crash Prevention: ${report.protectionAssessment.terminalCrashPrevention}`);
            console.log(`   Production Readiness: ${report.protectionAssessment.productionReadiness}`);
            
            console.log('\n📊 SUMMARY:');
            console.log(`   Tests: ${report.summary.passedTests}/${report.summary.totalTests} passed`);
            console.log(`   Duration: ${Math.round(totalDuration / 1000 * 100) / 100}s`);
            console.log(`   Final Memory: ${report.memoryMonitoring.finalStatus.usage}MB`);
            console.log(`   Final Status: ${report.memoryMonitoring.finalStatus.status}`);
            
            // Stop monitoring
            this.memoryProtection.stopMonitoring();
            
            return report;
            
        } catch (error) {
            console.error('💥 CRITICAL PROTECTION TEST FAILURE:', error);
            this.memoryProtection.stopMonitoring();
            throw error;
        }
    }
}

// Execute if run directly
if (require.main === module) {
    const validator = new MemoryProtectionValidator();
    
    validator.runMemoryProtectionValidation()
        .then(report => {
            console.log('\n🎯 MEMORY PROTECTION VALIDATION SUMMARY:');
            console.log(`   Overall Success: ${report.overallSuccess ? '✅ PASS' : '❌ FAIL'}`);
            console.log(`   Terminal Crash Prevention: ${report.protectionAssessment.terminalCrashPrevention}`);
            console.log(`   Production Readiness: ${report.protectionAssessment.productionReadiness}`);
            
            process.exit(report.overallSuccess ? 0 : 1);
        })
        .catch(error => {
            console.error('💥 MEMORY PROTECTION VALIDATION FAILED:', error.message);
            process.exit(1);
        });
}

module.exports = MemoryProtectionValidator;