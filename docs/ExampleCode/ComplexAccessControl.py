#!/usr/bin/env python3

"""
# Complex Access Control (Conceptual Example)

This script provides a conceptual example of a role-based access control (RBAC)
system with potential for attribute-based access control (ABAC) extension.
It demonstrates how to structure data and logic to check if a user has permission
to perform a specific action on a resource.

This is a simplified example focusing on the core concepts.
"""

from typing import Dict, Any, List, Optional
import json

# --- Conceptual Data Structures ---

class User:
    """
    Represents a user with assigned roles.
    """
    def __init__(self, user_id: str, roles: List[str]):
        self.user_id = user_id
        self.roles = roles

    def to_dict(self) -> Dict[str, Any]:
        return {
            "user_id": self.user_id,
            "roles": self.roles
        }

class Resource:
    """
    Represents a resource (e.g., object) being accessed.
    Could be a type (e.g., "Docket") or a specific instance (e.g., "Docket:docket_abc").
    Includes conceptual attributes for ABAC.
    """
    def __init__(self, resource_type: str, resource_id: Optional[str] = None, attributes: Optional[Dict[str, Any]] = None):
        self.resource_type = resource_type
        self.resource_id = resource_id
        self.attributes = attributes if attributes is not None else {}

    def to_dict(self) -> Dict[str, Any]:
        return {
            "resource_type": self.resource_type,
            "resource_id": self.resource_id,
            "attributes": self.attributes
        }

    def __str__(self) -> str:
        return f"{self.resource_type}{f':{self.resource_id}' if self.resource_id else ''}"

class Permission:
    """
    Defines what a role can do on a resource.
    """
    def __init__(self, role: str, resource_type: str, actions: List[str], condition: Optional[Dict[str, Any]] = None):
        self.role = role
        self.resource_type = resource_type
        self.actions = actions
        self.condition = condition # Conceptual condition for ABAC

    def to_dict(self) -> Dict[str, Any]:
        return {
            "role": self.role,
            "resource_type": self.resource_type,
            "actions": self.actions,
            "condition": self.condition
        }

class AccessPolicy:
    """
    A collection of permissions defining the access rules.
    """
    def __init__(self, permissions: List[Permission]):
        self.permissions = permissions

    def to_dict(self) -> Dict[str, Any]:
        return {
            "permissions": [p.to_dict() for p in self.permissions]
        }

    def get_permissions_for_resource_type(self, resource_type: str) -> List[Permission]:
        """
        Filters permissions relevant to a specific resource type.
        """
        return [p for p in self.permissions if p.resource_type == resource_type]

# --- Access Control Manager ---

class AccessControlManager:
    """
    Manages access checks against the policy.
    """
    def __init__(self, policy: AccessPolicy):
        self.policy = policy

    def can_access(self, user: User, action: str, resource: Resource) -> bool:
        """
        Checks if the user has permission to perform the action on the resource.
        """
        print(f"\n[AccessControlManager] Checking access for User '{user.user_id}' (Roles: {user.roles}) to perform '{action}' on Resource '{resource}'")

        # Iterate through each of the user's roles
        for user_role in user.roles:
            print(f"  Checking Role: '{user_role}'")
            # Find permissions in the policy that match the user's role and resource type
            relevant_permissions = [p for p in self.policy.get_permissions_for_resource_type(resource.resource_type) if p.role == user_role]

            for permission in relevant_permissions:
                print(f"    Evaluating Permission: Role='{permission.role}', Resource='{permission.resource_type}', Actions={permission.actions}")
                # Check if the requested action is allowed by this permission
                if action in permission.actions:
                    print(f"      Action '{action}' found in allowed actions.")
                    # --- Conceptual ABAC Condition Check ---
                    # If a condition exists, evaluate it.
                    if permission.condition:
                        print(f"      Evaluating condition: {permission.condition}")
                        # This is a placeholder for complex condition evaluation logic.
                        # In a real system, you'd parse the condition dictionary
                        # and check against resource attributes and user attributes.
                        # For this conceptual example, we'll simulate a simple check.
                        # Example condition: {'attribute': 'created_by', 'operator': '==', 'value_from': 'user.id'}
                        if self._evaluate_condition(user, resource, permission.condition):
                            print("      Condition met. Access Granted by this permission.")
                            return True # Access granted if action allowed and condition met
                        else:
                            print("      Condition not met. Access Denied by this permission (due to condition).")
                            # Continue checking other permissions for this role/resource
                    else:
                        print("      No condition found for this permission.")
                        return True # Access granted if action allowed and no condition
                else:
                    print(f"      Action '{action}' not found in allowed actions.")
                    # Continue checking other permissions for this role/resource

    # Define some conceptual resources
    docket_resource_type = Resource(resource_type="Docket")
    project_resource_type = Resource(resource_type="Project")
    user_resource_type = Resource(resource_type="User")
    specific_docket_resource = Resource(resource_type="Docket", resource_id="docket_abc", attributes={"created_by": "user_alice"})
    specific_project_resource = Resource(resource_type="Project", resource_id="project_123")

    # --- Access Checks --- #

    # Example 1: Project Manager viewing a Docket (should be allowed by Policy)
    print("\n--- Check 1: PM viewing Docket Type ---")
    if access_manager.can_access(user_bob, "view", docket_resource_type):
        print("Result: Access Granted")
    else:
        print("Result: Access Denied")

    # Example 2: Contractor editing a Project (should be denied by Policy)
    print("\n--- Check 2: Contractor editing Project Type ---")
    if access_manager.can_access(user_charlie, "edit", project_resource_type):
        print("Result: Access Granted")
    else:
        print("Result: Access Denied")

    # Example 3: Site Foreman deleting a User (should be denied by Policy)
    print("\n--- Check 3: Site Foreman deleting User Type ---")
    if access_manager.can_access(user_alice, "delete", user_resource_type):
        print("Result: Access Granted")
    else:
        print("Result: Access Denied")

    # Example 4: Project Manager editing a specific Docket (should be allowed by Policy)
    print("\n--- Check 4: PM editing Specific Docket ---")
    if access_manager.can_access(user_bob, "edit", specific_docket_resource):
         print("Result: Access Granted")
    else:
         print("Result: Access Denied")

    # Example 5: Contractor viewing a specific Docket (should be allowed by Policy)
    print("\n--- Check 5: Contractor viewing Specific Docket ---")
    if access_manager.can_access(user_charlie, "view", specific_docket_resource):
        print("Result: Access Granted")
    else:
        print("Result: Access Denied")

    # Example 6: Contractor editing a specific Docket (should be denied by Policy)
    # unless we add an ABAC condition, which is conceptually shown but not fully implemented
    print("\n--- Check 6: Contractor editing Specific Docket (No ABAC rule for this) ---")
    if access_manager.can_access(user_charlie, "edit", specific_docket_resource):
        print("Result: Access Granted")
    else:
        print("Result: Access Denied")

    # Example 7: User Alice editing a Docket she created (if ABAC condition were implemented)
    # Policy would need a permission like: contractor can edit Docket if resource.created_by == user.id
    print("\n--- Check 7: Alice editing her Docket (Conceptual ABAC) ---")
    # To test this conceptually, let's assume Alice is a 'Contractor' AND 'Project Manager'
    user_alice_contractor_pm = User(user_id="user_alice", roles=["Contractor", "Project Manager"])
    specific_docket_created_by_alice = Resource(resource_type="Docket", resource_id="docket_xyz", attributes={"created_by": "user_alice"})
    # If a policy for 'Contractor' with an ABAC condition allowing edit on own dockets existed, this would pass.
    # With the current policy, it will pass because she is a 'Project Manager'.
    if access_manager.can_access(user_alice_contractor_pm, "edit", specific_docket_created_by_alice):
        print("Result: Access Granted (via PM role in current policy)") # Or via ABAC if implemented
    else:
        print("Result: Access Denied")

    print("\nComplex Access Control Example Complete.")

if __name__ == "__main__":
    run_conceptual_access_control_example() 