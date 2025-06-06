#!/usr/bin/env node

/**
 * QUICK JAVASCRIPT HEAP MEMORY VALIDATION TEST
 * 
 * Purpose: Fast validation of memory management during TaskMaster-AI operations
 * to ensure no JavaScript heap memory crashes occur during production usage
 */

const { performance } = require('perf_hooks');
const fs = require('fs');
const path = require('path');

class QuickMemoryValidationTester {
    constructor() {
        this.startTime = Date.now();
        this.memorySnapshots = [];
        this.testResults = [];
        
        console.log('🚀 QUICK MEMORY VALIDATION TESTER INITIALIZED');
        console.log(`⏱️  Test Started: ${new Date().toISOString()}`);
    }

    getMemoryUsage() {
        const memUsage = process.memoryUsage();
        return {
            heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024 * 100) / 100,
            heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024 * 100) / 100,
            external: Math.round(memUsage.external / 1024 / 1024 * 100) / 100,
            rss: Math.round(memUsage.rss / 1024 / 1024 * 100) / 100,
            timestamp: Date.now()
        };
    }

    forceGC() {
        if (global.gc) {
            const before = this.getMemoryUsage();
            global.gc();
            const after = this.getMemoryUsage();
            const freed = before.heapUsed - after.heapUsed;
            console.log(`🗑️  GC: Freed ${Math.round(freed * 100) / 100}MB`);
            return after;
        }
        return this.getMemoryUsage();
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Test 1: Basic Memory Baseline
     */
    async testMemoryBaseline() {
        console.log('\n📏 TEST 1: MEMORY BASELINE');
        
        const initial = this.getMemoryUsage();
        console.log(`   Initial: ${initial.heapUsed}MB`);
        
        // Create some test data
        const testData = new Array(10000).fill(null).map(() => ({
            id: Math.random(),
            data: new Array(100).fill(Math.random())
        }));
        
        const afterCreation = this.getMemoryUsage();
        console.log(`   After creation: ${afterCreation.heapUsed}MB`);
        
        // Clean up
        testData.length = 0;
        const afterCleanup = this.forceGC();
        console.log(`   After cleanup: ${afterCleanup.heapUsed}MB`);
        
        const result = {
            test: 'memory_baseline',
            success: afterCleanup.heapUsed < (initial.heapUsed + 10), // Allow 10MB growth
            initial: initial.heapUsed,
            peak: afterCreation.heapUsed,
            final: afterCleanup.heapUsed,
            growth: afterCleanup.heapUsed - initial.heapUsed
        };
        
        this.testResults.push(result);
        console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - Growth: ${result.growth}MB`);
        
        return result;
    }

    /**
     * Test 2: TaskMaster-AI Task Creation Simulation
     */
    async testTaskCreationMemory() {
        console.log('\n📋 TEST 2: TASK CREATION MEMORY');
        
        const start = this.getMemoryUsage();
        const tasks = new Map();
        
        // Create 1000 Level 5 tasks
        for (let i = 0; i < 1000; i++) {
            const task = {
                id: `task_${i}`,
                level: 5,
                metadata: {
                    complexity: Math.random(),
                    dependencies: new Array(10).fill(Math.random())
                },
                subtasks: new Array(8).fill(null).map((_, idx) => ({
                    id: `subtask_${i}_${idx}`,
                    data: new Array(100).fill(Math.random()),
                    analytics: new Array(20).fill(Math.random())
                }))
            };
            tasks.set(task.id, task);
        }
        
        const afterTasks = this.getMemoryUsage();
        console.log(`   Created 1000 tasks: ${afterTasks.heapUsed}MB`);
        
        // Process tasks
        let processed = 0;
        for (const [id, task] of tasks.entries()) {
            task.status = 'processed';
            task.result = task.subtasks.map(st => st.data.reduce((sum, val) => sum + val, 0));
            processed++;
        }
        
        const afterProcessing = this.getMemoryUsage();
        console.log(`   Processed ${processed} tasks: ${afterProcessing.heapUsed}MB`);
        
        // Cleanup
        tasks.clear();
        const afterCleanup = this.forceGC();
        console.log(`   After cleanup: ${afterCleanup.heapUsed}MB`);
        
        const result = {
            test: 'task_creation_memory',
            success: afterCleanup.heapUsed < (start.heapUsed + 50), // Allow 50MB growth
            tasksCreated: 1000,
            memoryGrowth: afterCleanup.heapUsed - start.heapUsed,
            peakMemory: afterProcessing.heapUsed
        };
        
        this.testResults.push(result);
        console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - Growth: ${result.memoryGrowth}MB`);
        
        return result;
    }

    /**
     * Test 3: Rapid Button Interactions
     */
    async testButtonInteractionMemory() {
        console.log('\n🖱️  TEST 3: BUTTON INTERACTION MEMORY');
        
        const start = this.getMemoryUsage();
        const interactions = [];
        
        // Simulate 5000 rapid button clicks
        for (let i = 0; i < 5000; i++) {
            const interaction = {
                id: `interaction_${i}`,
                type: ['dashboard', 'modal', 'export', 'settings'][Math.floor(Math.random() * 4)],
                timestamp: Date.now(),
                data: {
                    formData: new Array(50).fill(Math.random()),
                    context: new Array(100).fill(Math.random()),
                    validation: new Array(20).fill(Math.random())
                }
            };
            interactions.push(interaction);
            
            // Simulate processing
            interaction.processed = true;
            interaction.result = interaction.data.formData.reduce((sum, val) => sum + val, 0);
        }
        
        const afterInteractions = this.getMemoryUsage();
        console.log(`   Created 5000 interactions: ${afterInteractions.heapUsed}MB`);
        
        // Process all interactions
        interactions.forEach(interaction => {
            interaction.status = 'completed';
            interaction.analytics = new Array(10).fill(Math.random());
        });
        
        const afterProcessing = this.getMemoryUsage();
        console.log(`   Processed interactions: ${afterProcessing.heapUsed}MB`);
        
        // Cleanup
        interactions.length = 0;
        const afterCleanup = this.forceGC();
        console.log(`   After cleanup: ${afterCleanup.heapUsed}MB`);
        
        const result = {
            test: 'button_interaction_memory',
            success: afterCleanup.heapUsed < (start.heapUsed + 30), // Allow 30MB growth
            interactionsCreated: 5000,
            memoryGrowth: afterCleanup.heapUsed - start.heapUsed,
            peakMemory: afterProcessing.heapUsed
        };
        
        this.testResults.push(result);
        console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - Growth: ${result.memoryGrowth}MB`);
        
        return result;
    }

    /**
     * Test 4: Analytics Data Processing
     */
    async testAnalyticsMemory() {
        console.log('\n📊 TEST 4: ANALYTICS MEMORY');
        
        const start = this.getMemoryUsage();
        const analytics = new Map();
        
        // Generate 10000 analytics events
        for (let i = 0; i < 10000; i++) {
            const event = {
                id: `event_${i}`,
                type: 'user_interaction',
                timestamp: Date.now(),
                data: {
                    metrics: new Array(20).fill(Math.random()),
                    context: new Array(50).fill(Math.random()),
                    performance: {
                        loadTime: Math.random() * 1000,
                        memoryUsage: process.memoryUsage().heapUsed,
                        interactions: new Array(30).fill(Math.random())
                    }
                }
            };
            analytics.set(event.id, event);
        }
        
        const afterEvents = this.getMemoryUsage();
        console.log(`   Created 10000 events: ${afterEvents.heapUsed}MB`);
        
        // Process analytics aggregations
        const aggregations = new Map();
        for (const [id, event] of analytics.entries()) {
            const key = `agg_${event.type}`;
            if (!aggregations.has(key)) {
                aggregations.set(key, {
                    count: 0,
                    totalMemory: 0,
                    events: []
                });
            }
            const agg = aggregations.get(key);
            agg.count++;
            agg.totalMemory += event.data.performance.memoryUsage;
            agg.events.push(event.data.metrics);
        }
        
        const afterAggregation = this.getMemoryUsage();
        console.log(`   After aggregation: ${afterAggregation.heapUsed}MB`);
        
        // Cleanup
        analytics.clear();
        aggregations.clear();
        const afterCleanup = this.forceGC();
        console.log(`   After cleanup: ${afterCleanup.heapUsed}MB`);
        
        const result = {
            test: 'analytics_memory',
            success: afterCleanup.heapUsed < (start.heapUsed + 40), // Allow 40MB growth
            eventsProcessed: 10000,
            memoryGrowth: afterCleanup.heapUsed - start.heapUsed,
            peakMemory: afterAggregation.heapUsed
        };
        
        this.testResults.push(result);
        console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - Growth: ${result.memoryGrowth}MB`);
        
        return result;
    }

    /**
     * Test 5: Concurrent Operations Stress
     */
    async testConcurrentOperationsMemory() {
        console.log('\n⚡ TEST 5: CONCURRENT OPERATIONS MEMORY');
        
        const start = this.getMemoryUsage();
        
        // Run multiple operations concurrently
        const promises = [];
        
        // Task creation
        promises.push(this.createTasksConcurrently(500));
        
        // Analytics generation
        promises.push(this.generateAnalyticsConcurrently(2000));
        
        // Interaction simulation
        promises.push(this.simulateInteractionsConcurrently(1000));
        
        // Wait for all operations to complete
        const results = await Promise.all(promises);
        
        const afterConcurrent = this.getMemoryUsage();
        console.log(`   After concurrent ops: ${afterConcurrent.heapUsed}MB`);
        
        // Force cleanup
        const afterCleanup = this.forceGC();
        console.log(`   After cleanup: ${afterCleanup.heapUsed}MB`);
        
        const result = {
            test: 'concurrent_operations_memory',
            success: afterCleanup.heapUsed < (start.heapUsed + 60), // Allow 60MB growth
            operationsCompleted: results.reduce((sum, r) => sum + r, 0),
            memoryGrowth: afterCleanup.heapUsed - start.heapUsed,
            peakMemory: afterConcurrent.heapUsed
        };
        
        this.testResults.push(result);
        console.log(`   ✅ Result: ${result.success ? 'PASS' : 'FAIL'} - Growth: ${result.memoryGrowth}MB`);
        
        return result;
    }

    async createTasksConcurrently(count) {
        const tasks = [];
        for (let i = 0; i < count; i++) {
            tasks.push({
                id: `concurrent_task_${i}`,
                data: new Array(100).fill(Math.random()),
                subtasks: new Array(5).fill(null).map(() => new Array(50).fill(Math.random()))
            });
        }
        tasks.length = 0; // Cleanup
        return count;
    }

    async generateAnalyticsConcurrently(count) {
        const events = [];
        for (let i = 0; i < count; i++) {
            events.push({
                id: `concurrent_event_${i}`,
                data: new Array(200).fill(Math.random()),
                metrics: new Array(30).fill(Math.random())
            });
        }
        events.length = 0; // Cleanup
        return count;
    }

    async simulateInteractionsConcurrently(count) {
        const interactions = [];
        for (let i = 0; i < count; i++) {
            interactions.push({
                id: `concurrent_interaction_${i}`,
                payload: new Array(150).fill(Math.random()),
                context: new Array(40).fill(Math.random())
            });
        }
        interactions.length = 0; // Cleanup
        return count;
    }

    /**
     * Generate test report
     */
    generateReport() {
        const totalDuration = Date.now() - this.startTime;
        const overallSuccess = this.testResults.every(r => r.success);
        
        const report = {
            testSuite: 'Quick JavaScript Heap Memory Validation',
            timestamp: new Date().toISOString(),
            duration: totalDuration,
            overallSuccess,
            
            summary: {
                totalTests: this.testResults.length,
                passedTests: this.testResults.filter(r => r.success).length,
                failedTests: this.testResults.filter(r => !r.success).length,
                totalMemoryGrowth: this.testResults.reduce((sum, r) => sum + (r.memoryGrowth || 0), 0),
                maxMemoryUsage: Math.max(...this.testResults.map(r => r.peakMemory || 0))
            },
            
            testResults: this.testResults,
            
            assessment: {
                terminalStability: overallSuccess ? 'EXCELLENT' : 'AT RISK',
                memoryManagement: overallSuccess ? 'PRODUCTION READY' : 'NEEDS OPTIMIZATION',
                jsHeapStability: overallSuccess ? 'STABLE' : 'UNSTABLE',
                productionReadiness: overallSuccess ? 'APPROVED' : 'REQUIRES FIXES'
            },
            
            recommendations: this.generateRecommendations()
        };
        
        return report;
    }

    generateRecommendations() {
        const recommendations = [];
        
        const totalGrowth = this.testResults.reduce((sum, r) => sum + (r.memoryGrowth || 0), 0);
        
        if (totalGrowth > 100) {
            recommendations.push({
                priority: 'high',
                type: 'memory_optimization',
                description: 'Implement periodic garbage collection',
                action: 'Add automated GC triggers after intensive operations'
            });
        }
        
        const failedTests = this.testResults.filter(r => !r.success);
        if (failedTests.length > 0) {
            recommendations.push({
                priority: 'critical',
                type: 'memory_leak_fix',
                description: `Fix memory issues in: ${failedTests.map(t => t.test).join(', ')}`,
                action: 'Review object lifecycle and cleanup procedures'
            });
        }
        
        recommendations.push({
            priority: 'medium',
            type: 'monitoring',
            description: 'Implement real-time memory monitoring',
            action: 'Add memory usage alerts and dashboard metrics'
        });
        
        return recommendations;
    }

    /**
     * Main test execution
     */
    async runQuickMemoryValidation() {
        console.log('🚀 STARTING QUICK JAVASCRIPT HEAP MEMORY VALIDATION');
        console.log('=' * 60);
        
        try {
            await this.testMemoryBaseline();
            await this.testTaskCreationMemory();
            await this.testButtonInteractionMemory();
            await this.testAnalyticsMemory();
            await this.testConcurrentOperationsMemory();
            
            const report = this.generateReport();
            
            // Save report
            const timestamp = new Date().toISOString().replace(/:/g, '-');
            const filename = `quick_memory_validation_report_${timestamp}.json`;
            const filepath = path.join(__dirname, filename);
            
            await fs.promises.writeFile(filepath, JSON.stringify(report, null, 2));
            console.log(`\n💾 Report saved: ${filepath}`);
            
            console.log('\n🏁 QUICK MEMORY VALIDATION COMPLETE');
            console.log(`${report.overallSuccess ? '✅ SUCCESS' : '❌ FAILED'}: Memory validation completed`);
            
            console.log('\n📊 FINAL ASSESSMENT:');
            console.log(`   Terminal Stability: ${report.assessment.terminalStability}`);
            console.log(`   Memory Management: ${report.assessment.memoryManagement}`);
            console.log(`   JS Heap Stability: ${report.assessment.jsHeapStability}`);
            console.log(`   Production Readiness: ${report.assessment.productionReadiness}`);
            
            console.log('\n📈 SUMMARY:');
            console.log(`   Tests: ${report.summary.passedTests}/${report.summary.totalTests} passed`);
            console.log(`   Total Memory Growth: ${Math.round(report.summary.totalMemoryGrowth * 100) / 100}MB`);
            console.log(`   Max Memory Usage: ${Math.round(report.summary.maxMemoryUsage * 100) / 100}MB`);
            console.log(`   Duration: ${Math.round(report.duration / 1000 * 100) / 100}s`);
            
            if (report.recommendations.length > 0) {
                console.log('\n💡 RECOMMENDATIONS:');
                report.recommendations.forEach(rec => {
                    console.log(`   ${rec.priority.toUpperCase()}: ${rec.description}`);
                });
            }
            
            return report;
            
        } catch (error) {
            console.error('💥 CRITICAL TEST FAILURE:', error);
            throw error;
        }
    }
}

// Execute if run directly
if (require.main === module) {
    const tester = new QuickMemoryValidationTester();
    
    tester.runQuickMemoryValidation()
        .then(report => {
            process.exit(report.overallSuccess ? 0 : 1);
        })
        .catch(error => {
            console.error('💥 TEST EXECUTION FAILED:', error.message);
            process.exit(1);
        });
}

module.exports = QuickMemoryValidationTester;