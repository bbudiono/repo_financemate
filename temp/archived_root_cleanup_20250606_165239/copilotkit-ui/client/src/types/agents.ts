/*
* Purpose: Core TypeScript types for Multi-Agent coordination and CopilotKit integration
* Issues & Complexity Summary: Comprehensive type definitions for multi-LLM agent system with tier restrictions
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~300
  - Core Algorithm Complexity: Medium
  - Dependencies: 2 New (CopilotKit types, Multi-agent types)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 72%
* Justification for Estimates: Complex type definitions but well-defined domain
* Final Code Complexity (Actual %): 74%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Comprehensive type safety essential for multi-agent coordination
* Last Updated: 2025-06-03
*/

export type UserTier = 'free' | 'pro' | 'enterprise';

export interface User {
  id: string;
  tier: UserTier;
  name: string;
  email: string;
  preferences: UserPreferences;
}

export interface UserPreferences {
  agentTypes: AgentType[];
  optimizationLevel: 'basic' | 'advanced' | 'maximum';
  useAppleSiliconOptimization: boolean;
  maxConcurrentAgents: number;
}

export type AgentType = 
  | 'research'
  | 'creative'
  | 'technical'
  | 'financial'
  | 'video_generation'
  | 'document_processing'
  | 'analytics';

export type AgentStatus = 'idle' | 'active' | 'busy' | 'error' | 'offline';

export interface Agent {
  id: string;
  type: AgentType;
  name: string;
  status: AgentStatus;
  currentTask?: string;
  capabilities: AgentCapability[];
  performance: AgentPerformance;
  lastActivity: Date;
  tier: UserTier; // Minimum tier required
}

export interface AgentCapability {
  name: string;
  description: string;
  complexity: 'low' | 'medium' | 'high';
  requiresTier: UserTier;
}

export interface AgentPerformance {
  tasksCompleted: number;
  averageResponseTime: number; // in milliseconds
  successRate: number; // 0-1
  lastResponse: Date;
}

export type TaskPriority = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10;

export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'failed' | 'cancelled';

export interface MultiLLMTask {
  id: string;
  description: string;
  type: AgentType[];
  priority: TaskPriority;
  status: TaskStatus;
  assignedAgents: string[];
  requiredCapabilities: string[];
  estimatedCompletion?: Date;
  progress: number; // 0-100
  userTier: UserTier;
  metadata: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}

export interface CoordinationRequest {
  taskDescription: string;
  agentPreferences?: AgentType[];
  priorityLevel?: TaskPriority;
  userTier: UserTier;
  maxAgents?: number;
  timeoutMinutes?: number;
}

export interface CoordinationResponse {
  coordinationId: string;
  assignedAgents: Agent[];
  estimatedCompletion: Date;
  workflowGraph: WorkflowNode[];
  resourceAllocation: ResourceAllocation;
}

export interface WorkflowNode {
  id: string;
  type: 'agent' | 'decision' | 'merge' | 'condition';
  agentType?: AgentType;
  dependencies: string[];
  status: 'pending' | 'running' | 'completed' | 'error';
  output?: any;
  executionTime?: number;
}

export interface ResourceAllocation {
  cpuCores: number;
  memoryGB: number;
  useNeuralEngine: boolean;
  useGPUAcceleration: boolean;
  estimatedPowerUsage: number; // watts
}

// LangGraph Integration Types
export interface LangGraphWorkflow {
  id: string;
  name: string;
  description: string;
  nodes: LangGraphNode[];
  edges: LangGraphEdge[];
  status: 'draft' | 'active' | 'paused' | 'completed';
  userTier: UserTier;
}

export interface LangGraphNode {
  id: string;
  type: 'start' | 'agent' | 'condition' | 'merge' | 'end';
  label: string;
  agentType?: AgentType;
  config: Record<string, any>;
  position: { x: number; y: number };
}

export interface LangGraphEdge {
  id: string;
  source: string;
  target: string;
  condition?: string;
  label?: string;
}

export interface ExecutionState {
  currentNode?: string;
  completedNodes: string[];
  nodeStates: Record<string, any>;
  startTime: Date;
  lastUpdate: Date;
}

// Apple Silicon Optimization Types
export interface HardwareMetrics {
  neuralEngine: {
    utilization: number; // 0-100
    status: 'idle' | 'active' | 'overloaded';
    temperature: number;
  };
  gpu: {
    utilization: number; // 0-100
    status: 'idle' | 'active' | 'overloaded';
    memory: number; // GB used
  };
  cpu: {
    performanceCores: number;
    efficiencyCores: number;
    utilization: number; // 0-100
    temperature: number;
  };
  memory: {
    used: number; // GB
    available: number; // GB
    pressure: 'low' | 'medium' | 'high';
    status: 'normal' | 'warning' | 'critical';
  };
  thermal: {
    state: 'nominal' | 'fair' | 'serious' | 'critical';
    status: 'normal' | 'throttling' | 'emergency';
  };
}

export interface OptimizationSettings {
  level: 'basic' | 'advanced' | 'maximum';
  useNeuralEngine: boolean;
  useGPUAcceleration: boolean;
  cpuCoreAllocation: 'auto' | 'performance' | 'efficiency' | 'mixed';
  memoryOptimization: boolean;
  thermalManagement: 'auto' | 'aggressive' | 'conservative';
}

// Video Generation Types (Enterprise only)
export interface VideoProject {
  id: string;
  concept: string;
  duration: number; // seconds
  style: 'realistic' | 'animated' | 'artistic' | 'documentary';
  status: 'queued' | 'generating' | 'completed' | 'failed';
  progress: number; // 0-100
  previewUrl?: string;
  finalUrl?: string;
  createdAt: Date;
  estimatedCompletion?: Date;
}

export interface GenerationStatus {
  [projectId: string]: 'not_started' | 'generating' | 'completed' | 'failed';
}

// Agent Communication Types
export interface AgentCommunication {
  id: string;
  timestamp: Date;
  fromAgent: string;
  toAgent: string;
  type: 'external' | 'internal' | 'coordination' | 'error';
  message: string;
  summary: string;
  metadata: Record<string, any>;
}

export interface CommunicationAnalysis {
  count: number;
  efficiency: number; // 0-1
  bottlenecks: string[];
  recommendations: string[];
  patterns: CommunicationPattern[];
}

export interface CommunicationPattern {
  type: 'frequent_exchange' | 'bottleneck' | 'isolation' | 'efficiency';
  agents: string[];
  description: string;
  impact: 'positive' | 'negative' | 'neutral';
}

// Tier Configuration
export interface TierCapabilities {
  maxAgents: number;
  allowedAgentTypes: AgentType[];
  optimizationLevel: OptimizationSettings['level'];
  videoGeneration: boolean;
  internalCommunicationAccess: boolean;
  workflowModification: boolean;
  appleSiliconOptimization: boolean;
  realTimeMetrics: boolean;
}

export const TIER_CAPABILITIES: Record<UserTier, TierCapabilities> = {
  free: {
    maxAgents: 2,
    allowedAgentTypes: ['research', 'technical'],
    optimizationLevel: 'basic',
    videoGeneration: false,
    internalCommunicationAccess: false,
    workflowModification: false,
    appleSiliconOptimization: false,
    realTimeMetrics: false
  },
  pro: {
    maxAgents: 5,
    allowedAgentTypes: ['research', 'technical', 'creative', 'financial', 'analytics'],
    optimizationLevel: 'advanced',
    videoGeneration: false,
    internalCommunicationAccess: false,
    workflowModification: true,
    appleSiliconOptimization: true,
    realTimeMetrics: true
  },
  enterprise: {
    maxAgents: 10,
    allowedAgentTypes: ['research', 'technical', 'creative', 'financial', 'analytics', 'video_generation', 'document_processing'],
    optimizationLevel: 'maximum',
    videoGeneration: true,
    internalCommunicationAccess: true,
    workflowModification: true,
    appleSiliconOptimization: true,
    realTimeMetrics: true
  }
};

// Error Types
export interface AgentError {
  code: string;
  message: string;
  timestamp: Date;
  agentId?: string;
  taskId?: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  recoverable: boolean;
}