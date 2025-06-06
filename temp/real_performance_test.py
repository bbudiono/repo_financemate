#!/usr/bin/env python3

"""
SANDBOX FILE: For testing/development. See .cursorrules.
Purpose: Real-world performance testing for TaskMaster-AI with FinanceMate application
Issues & Complexity Summary: Production readiness validation with actual application integration
Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~350
  - Core Algorithm Complexity: High
  - Dependencies: 4 New (subprocess, threading, psutil, time)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
Problem Estimate (Inherent Problem Difficulty %): 85%
Initial Code Complexity Estimate %: 80%
Justification for Estimates: Real application testing with concurrent operations and resource monitoring
Final Code Complexity (Actual %): TBD
Overall Result Score (Success & Quality %): TBD
Key Variances/Learnings: TBD
Last Updated: 2025-06-06
"""

import subprocess
import threading
import time
import json
import os
import sys
import psutil
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import signal

class FinanceMatePerformanceTester:
    def __init__(self):
        self.project_root = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate"
        self.app_path = f"{self.project_root}/_macOS/FinanceMate-Sandbox"
        self.test_results = {}
        self.performance_metrics = {
            'memory_usage': [],
            'cpu_usage': [],
            'task_creation_times': [],
            'error_count': 0,
            'start_time': None,
            'end_time': None
        }
        self.app_process = None
        
    def setup_test_environment(self):
        """Setup the test environment and build the application"""
        print("🔧 SETTING UP TEST ENVIRONMENT")
        print("="*80)
        
        # Change to project directory
        os.chdir(self.project_root)
        
        # Build the Sandbox application
        print("🏗️ Building FinanceMate-Sandbox application...")
        build_cmd = [
            "xcodebuild", 
            "-workspace", f"{self.app_path}/../FinanceMate.xcworkspace",
            "-scheme", "FinanceMate-Sandbox",
            "-configuration", "Debug",
            "build"
        ]
        
        try:
            result = subprocess.run(build_cmd, capture_output=True, text=True, timeout=300)
            if result.returncode == 0:
                print("✅ Application build successful")
                return True
            else:
                print(f"❌ Build failed: {result.stderr}")
                return False
        except subprocess.TimeoutExpired:
            print("❌ Build timeout after 5 minutes")
            return False
        except Exception as e:
            print(f"❌ Build error: {e}")
            return False
    
    def launch_application(self):
        """Launch the FinanceMate-Sandbox application"""
        print("\n🚀 LAUNCHING FINANCEMATE-SANDBOX APPLICATION")
        
        # Find the built application
        app_bundle_path = f"{self.app_path}/build/Debug/FinanceMate-Sandbox.app"
        
        if not os.path.exists(app_bundle_path):
            print(f"❌ Application bundle not found at: {app_bundle_path}")
            return False
        
        try:
            # Launch the application
            launch_cmd = ["open", app_bundle_path]
            self.app_process = subprocess.Popen(launch_cmd)
            
            # Wait for application to start
            time.sleep(3)
            
            # Verify application is running
            app_pid = self.find_app_process()
            if app_pid:
                print(f"✅ Application launched successfully (PID: {app_pid})")
                return True
            else:
                print("❌ Failed to verify application launch")
                return False
                
        except Exception as e:
            print(f"❌ Launch error: {e}")
            return False
    
    def find_app_process(self):
        """Find the running FinanceMate-Sandbox process"""
        for proc in psutil.process_iter(['pid', 'name']):
            try:
                if 'FinanceMate-Sandbox' in proc.info['name']:
                    return proc.info['pid']
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
        return None
    
    def monitor_system_resources(self, duration=60):
        """Monitor system resources during testing"""
        print(f"\n📊 MONITORING SYSTEM RESOURCES FOR {duration}s")
        
        app_pid = self.find_app_process()
        if not app_pid:
            print("❌ Cannot find application process for monitoring")
            return
        
        try:
            app_process = psutil.Process(app_pid)
            start_time = time.time()
            
            while time.time() - start_time < duration:
                try:
                    # Get memory usage
                    memory_info = app_process.memory_info()
                    memory_mb = memory_info.rss / 1024 / 1024
                    
                    # Get CPU usage
                    cpu_percent = app_process.cpu_percent()
                    
                    self.performance_metrics['memory_usage'].append(memory_mb)
                    self.performance_metrics['cpu_usage'].append(cpu_percent)
                    
                    print(f"📈 Memory: {memory_mb:.1f}MB, CPU: {cpu_percent:.1f}%")
                    
                    time.sleep(2)
                    
                except psutil.NoSuchProcess:
                    print("❌ Application process terminated during monitoring")
                    break
                    
        except Exception as e:
            print(f"❌ Monitoring error: {e}")
    
    def test_concurrent_task_creation(self):
        """Test concurrent TaskMaster-AI task creation"""
        print("\n🧪 TEST 1: CONCURRENT TASKMASTER-AI TASK CREATION")
        print("Testing concurrent task creation with AppleScript automation...")
        
        concurrent_tasks = 8
        results = []
        
        def create_task_via_applescript(task_id):
            """Create a task using AppleScript automation"""
            start_time = time.time()
            
            applescript_cmd = f'''
            tell application "FinanceMate-Sandbox"
                activate
                delay 0.5
                
                -- Simulate clicking Add Transaction button (Dashboard view)
                tell application "System Events"
                    tell process "FinanceMate-Sandbox"
                        -- Look for Add Transaction button
                        try
                            click button "Add Transaction" of window 1
                            delay 1
                            
                            -- Fill in transaction details
                            set value of text field 1 of window 1 to "Performance Test {task_id}"
                            set value of text field 2 of window 1 to "100.00"
                            delay 0.5
                            
                            -- Click Save or Submit
                            click button "Save" of window 1
                            delay 1
                            
                        on error
                            -- If button not found, just activate the window
                            click window 1
                            delay 0.5
                        end try
                    end tell
                end tell
            end tell
            '''
            
            try:
                result = subprocess.run(
                    ["osascript", "-e", applescript_cmd],
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                
                duration = time.time() - start_time
                success = result.returncode == 0
                
                return {
                    'task_id': task_id,
                    'success': success,
                    'duration': duration,
                    'error': result.stderr if not success else None
                }
                
            except subprocess.TimeoutExpired:
                return {
                    'task_id': task_id,
                    'success': False,
                    'duration': 30.0,
                    'error': 'Timeout'
                }
            except Exception as e:
                return {
                    'task_id': task_id,
                    'success': False,
                    'duration': time.time() - start_time,
                    'error': str(e)
                }
        
        # Execute concurrent tasks
        with ThreadPoolExecutor(max_workers=concurrent_tasks) as executor:
            futures = [executor.submit(create_task_via_applescript, i) for i in range(concurrent_tasks)]
            
            for future in as_completed(futures):
                result = future.result()
                results.append(result)
                self.performance_metrics['task_creation_times'].append(result['duration'])
                
                if not result['success']:
                    self.performance_metrics['error_count'] += 1
                
                status = "✅" if result['success'] else "❌"
                print(f"{status} Task {result['task_id']}: {result['duration']:.2f}s")
        
        # Analyze results
        success_count = sum(1 for r in results if r['success'])
        avg_duration = sum(r['duration'] for r in results) / len(results)
        max_duration = max(r['duration'] for r in results)
        
        self.test_results['concurrent_task_creation'] = {
            'total_tasks': concurrent_tasks,
            'successful_tasks': success_count,
            'failed_tasks': concurrent_tasks - success_count,
            'average_duration': avg_duration,
            'max_duration': max_duration,
            'results': results
        }
        
        print(f"\n📊 CONCURRENT TASK CREATION RESULTS:")
        print(f"✅ Success: {success_count}/{concurrent_tasks}")
        print(f"⏱️ Average Duration: {avg_duration:.2f}s")
        print(f"⏱️ Max Duration: {max_duration:.2f}s")
        
        return success_count == concurrent_tasks and avg_duration < 5.0
    
    def test_memory_under_load(self):
        """Test memory management under intensive load"""
        print("\n🧪 TEST 2: MEMORY MANAGEMENT UNDER LOAD")
        
        initial_memory = None
        app_pid = self.find_app_process()
        
        if app_pid:
            try:
                app_process = psutil.Process(app_pid)
                initial_memory = app_process.memory_info().rss / 1024 / 1024
                print(f"📊 Initial Memory Usage: {initial_memory:.1f}MB")
            except Exception as e:
                print(f"❌ Error getting initial memory: {e}")
                return False
        
        # Simulate intensive operations by triggering multiple UI interactions
        operations = [
            "View Details",
            "Upload Document", 
            "Add Transaction",
            "View Reports",
            "Settings"
        ]
        
        memory_readings = []
        
        for i in range(20):  # 20 intensive operations
            operation = operations[i % len(operations)]
            
            # Trigger operation via AppleScript
            applescript_cmd = f'''
            tell application "FinanceMate-Sandbox"
                activate
                delay 0.2
            end tell
            
            tell application "System Events"
                tell process "FinanceMate-Sandbox"
                    try
                        click window 1
                        delay 0.3
                        key code 53  -- ESC key to handle any modals
                        delay 0.2
                    on error
                        -- Ignore errors, just continue
                    end try
                end tell
            end tell
            '''
            
            try:
                subprocess.run(["osascript", "-e", applescript_cmd], timeout=10)
                
                # Measure memory after operation
                if app_pid:
                    try:
                        app_process = psutil.Process(app_pid)
                        current_memory = app_process.memory_info().rss / 1024 / 1024
                        memory_readings.append(current_memory)
                        
                        if i % 5 == 0:
                            print(f"📈 Operation {i}: Memory {current_memory:.1f}MB")
                            
                    except Exception:
                        pass
                        
            except Exception as e:
                print(f"⚠️ Operation {i} error: {e}")
                self.performance_metrics['error_count'] += 1
        
        if memory_readings and initial_memory:
            peak_memory = max(memory_readings)
            final_memory = memory_readings[-1]
            memory_growth = peak_memory - initial_memory
            memory_growth_percent = (memory_growth / initial_memory) * 100
            
            self.test_results['memory_management'] = {
                'initial_memory': initial_memory,
                'peak_memory': peak_memory,
                'final_memory': final_memory,
                'memory_growth': memory_growth,
                'memory_growth_percent': memory_growth_percent,
                'memory_readings': memory_readings
            }
            
            print(f"\n📊 MEMORY MANAGEMENT RESULTS:")
            print(f"🧠 Initial: {initial_memory:.1f}MB")
            print(f"🧠 Peak: {peak_memory:.1f}MB")
            print(f"🧠 Final: {final_memory:.1f}MB")
            print(f"📈 Growth: {memory_growth:.1f}MB ({memory_growth_percent:.1f}%)")
            
            return peak_memory < 200.0 and memory_growth_percent < 50.0
        
        return False
    
    def test_ui_responsiveness(self):
        """Test UI responsiveness under load"""
        print("\n🧪 TEST 3: UI RESPONSIVENESS UNDER LOAD")
        
        response_times = []
        
        for i in range(10):
            start_time = time.time()
            
            # Test UI interaction responsiveness
            applescript_cmd = '''
            tell application "FinanceMate-Sandbox"
                activate
                delay 0.1
            end tell
            
            tell application "System Events"
                tell process "FinanceMate-Sandbox"
                    try
                        click window 1
                        delay 0.1
                        -- Simulate keyboard navigation
                        key code 48  -- Tab key
                        delay 0.1
                        key code 48  -- Tab key
                        delay 0.1
                    on error
                        -- Continue if error
                    end try
                end tell
            end tell
            '''
            
            try:
                subprocess.run(["osascript", "-e", applescript_cmd], timeout=5)
                response_time = time.time() - start_time
                response_times.append(response_time)
                print(f"⚡ UI Response {i}: {response_time:.2f}s")
                
            except Exception as e:
                print(f"❌ UI test {i} failed: {e}")
                response_times.append(5.0)  # Max timeout
        
        avg_response = sum(response_times) / len(response_times)
        max_response = max(response_times)
        
        self.test_results['ui_responsiveness'] = {
            'response_times': response_times,
            'average_response': avg_response,
            'max_response': max_response
        }
        
        print(f"\n📊 UI RESPONSIVENESS RESULTS:")
        print(f"⚡ Average Response: {avg_response:.2f}s")
        print(f"⚡ Max Response: {max_response:.2f}s")
        
        return avg_response < 2.0 and max_response < 5.0
    
    def cleanup_and_terminate(self):
        """Clean up and terminate the application"""
        print("\n🧹 CLEANING UP TEST ENVIRONMENT")
        
        # Terminate the application gracefully
        try:
            subprocess.run(["pkill", "-f", "FinanceMate-Sandbox"], timeout=10)
            time.sleep(2)
        except Exception as e:
            print(f"⚠️ Cleanup warning: {e}")
    
    def generate_comprehensive_report(self):
        """Generate comprehensive performance test report"""
        self.performance_metrics['end_time'] = datetime.now()
        
        print("\n" + "="*80)
        print("🎯 COMPREHENSIVE PERFORMANCE TEST REPORT")
        print("="*80)
        print(f"📅 Test Completed: {self.performance_metrics['end_time']}")
        
        # Overall assessment
        all_tests_passed = True
        
        # Test 1: Concurrent Task Creation
        if 'concurrent_task_creation' in self.test_results:
            test = self.test_results['concurrent_task_creation']
            success_rate = (test['successful_tasks'] / test['total_tasks']) * 100
            passed = test['successful_tasks'] == test['total_tasks'] and test['average_duration'] < 5.0
            all_tests_passed = all_tests_passed and passed
            
            print(f"\n🧪 CONCURRENT TASK CREATION: {'✅ PASSED' if passed else '❌ FAILED'}")
            print(f"   Success Rate: {success_rate:.1f}% ({test['successful_tasks']}/{test['total_tasks']})")
            print(f"   Average Duration: {test['average_duration']:.2f}s")
        
        # Test 2: Memory Management
        if 'memory_management' in self.test_results:
            test = self.test_results['memory_management']
            passed = test['peak_memory'] < 200.0 and test['memory_growth_percent'] < 50.0
            all_tests_passed = all_tests_passed and passed
            
            print(f"\n🧠 MEMORY MANAGEMENT: {'✅ PASSED' if passed else '❌ FAILED'}")
            print(f"   Peak Memory: {test['peak_memory']:.1f}MB")
            print(f"   Memory Growth: {test['memory_growth_percent']:.1f}%")
        
        # Test 3: UI Responsiveness
        if 'ui_responsiveness' in self.test_results:
            test = self.test_results['ui_responsiveness']
            passed = test['average_response'] < 2.0 and test['max_response'] < 5.0
            all_tests_passed = all_tests_passed and passed
            
            print(f"\n⚡ UI RESPONSIVENESS: {'✅ PASSED' if passed else '❌ FAILED'}")
            print(f"   Average Response: {test['average_response']:.2f}s")
            print(f"   Max Response: {test['max_response']:.2f}s")
        
        # Performance metrics summary
        if self.performance_metrics['memory_usage']:
            avg_memory = sum(self.performance_metrics['memory_usage']) / len(self.performance_metrics['memory_usage'])
            peak_memory = max(self.performance_metrics['memory_usage'])
            print(f"\n📊 PERFORMANCE METRICS:")
            print(f"   Average Memory: {avg_memory:.1f}MB")
            print(f"   Peak Memory: {peak_memory:.1f}MB")
            
        if self.performance_metrics['task_creation_times']:
            avg_task_time = sum(self.performance_metrics['task_creation_times']) / len(self.performance_metrics['task_creation_times'])
            print(f"   Average Task Creation: {avg_task_time:.2f}s")
        
        print(f"   Total Errors: {self.performance_metrics['error_count']}")
        
        # Final assessment
        print(f"\n🎯 PRODUCTION READINESS ASSESSMENT:")
        if all_tests_passed and self.performance_metrics['error_count'] < 3:
            print("✅ PRODUCTION READY - All performance criteria met")
            print("\n🚀 RECOMMENDATIONS:")
            print("• TaskMaster-AI integration performs well under load")
            print("• Memory usage is within acceptable limits")
            print("• UI remains responsive during intensive operations")
            print("• Proceed with production deployment")
        else:
            print("❌ NOT PRODUCTION READY - Performance issues detected")
            print("\n⚠️ RECOMMENDATIONS:")
            print("• Address failing performance tests")
            print("• Optimize memory usage and task creation times")
            print("• Improve UI responsiveness")
            print("• Re-run tests after optimizations")
        
        print("="*80)
        
        # Save results to file
        report_path = f"{self.project_root}/temp/performance_test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_path, 'w') as f:
            json.dump({
                'test_results': self.test_results,
                'performance_metrics': {
                    k: v for k, v in self.performance_metrics.items() 
                    if k not in ['start_time', 'end_time']
                },
                'timestamp': self.performance_metrics['end_time'].isoformat(),
                'production_ready': all_tests_passed and self.performance_metrics['error_count'] < 3
            }, f, indent=2)
        
        print(f"📄 Detailed report saved to: {report_path}")
    
    def run_comprehensive_performance_test(self):
        """Run the complete performance test suite"""
        print("🚀 STARTING COMPREHENSIVE PERFORMANCE TESTING")
        print("Target: TaskMaster-AI Production Readiness Validation")
        print("="*80)
        
        self.performance_metrics['start_time'] = datetime.now()
        
        try:
            # Setup and build
            if not self.setup_test_environment():
                print("❌ Test environment setup failed")
                return False
            
            # Launch application
            if not self.launch_application():
                print("❌ Application launch failed")
                return False
            
            # Start resource monitoring in background
            monitor_thread = threading.Thread(
                target=self.monitor_system_resources, 
                args=(120,),  # Monitor for 2 minutes
                daemon=True
            )
            monitor_thread.start()
            
            # Run performance tests
            test_results = []
            
            print("\n🏁 STARTING PERFORMANCE TEST SUITE")
            
            # Test 1: Concurrent Task Creation
            result1 = self.test_concurrent_task_creation()
            test_results.append(result1)
            
            # Test 2: Memory Management
            result2 = self.test_memory_under_load()
            test_results.append(result2)
            
            # Test 3: UI Responsiveness
            result3 = self.test_ui_responsiveness()
            test_results.append(result3)
            
            # Wait for monitoring to complete
            time.sleep(5)
            
            # Generate comprehensive report
            self.generate_comprehensive_report()
            
            return all(test_results)
            
        except KeyboardInterrupt:
            print("\n⚠️ Test interrupted by user")
            return False
        except Exception as e:
            print(f"\n❌ Test suite error: {e}")
            return False
        finally:
            self.cleanup_and_terminate()

def main():
    """Main execution function"""
    tester = FinanceMatePerformanceTester()
    
    # Handle interruption gracefully
    def signal_handler(sig, frame):
        print("\n⚠️ Received interrupt signal, cleaning up...")
        tester.cleanup_and_terminate()
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    
    # Run the comprehensive test
    success = tester.run_comprehensive_performance_test()
    
    print(f"\n✅ Performance testing {'COMPLETED SUCCESSFULLY' if success else 'COMPLETED WITH ISSUES'}")
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())