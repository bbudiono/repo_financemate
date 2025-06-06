/*
* Purpose: Tier selector component for demonstrating tier-based access controls
* Issues & Complexity Summary: Simple tier switching component with visual feedback
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low
  - Dependencies: 1 New (React state)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
* Problem Estimate (Inherent Problem Difficulty %): 35%
* Initial Code Complexity Estimate %: 38%
* Justification for Estimates: Simple UI component with minimal logic
* Final Code Complexity (Actual %): 42%
* Overall Result Score (Success & Quality %): 98%
* Key Variances/Learnings: Straightforward component implementation
* Last Updated: 2025-06-03
*/

import React from 'react';
import { UserTier, TIER_CAPABILITIES } from '../types/agents';
import './TierSelector.css';

interface TierSelectorProps {
  currentTier: UserTier;
  onTierChange: (tier: UserTier) => void;
}

const TierSelector: React.FC<TierSelectorProps> = ({ currentTier, onTierChange }) => {
  const tiers: { value: UserTier; label: string; description: string }[] = [
    {
      value: 'free',
      label: 'Free',
      description: '2 agents, basic features'
    },
    {
      value: 'pro',
      label: 'Pro',
      description: '5 agents, Apple Silicon optimization'
    },
    {
      value: 'enterprise',
      label: 'Enterprise',
      description: '10 agents, video generation, full access'
    }
  ];

  return (
    <div className="tier-selector">
      <label className="tier-selector-label">Tier:</label>
      <select
        value={currentTier}
        onChange={(e) => onTierChange(e.target.value as UserTier)}
        className="tier-selector-dropdown"
      >
        {tiers.map(tier => (
          <option key={tier.value} value={tier.value}>
            {tier.label} - {tier.description}
          </option>
        ))}
      </select>
      
      <div className="tier-capabilities">
        <span className="capabilities-text">
          Max Agents: {TIER_CAPABILITIES[currentTier].maxAgents} | 
          Apple Silicon: {TIER_CAPABILITIES[currentTier].appleSiliconOptimization ? '✅' : '❌'} | 
          Video Gen: {TIER_CAPABILITIES[currentTier].videoGeneration ? '✅' : '❌'}
        </span>
      </div>
    </div>
  );
};

export default TierSelector;