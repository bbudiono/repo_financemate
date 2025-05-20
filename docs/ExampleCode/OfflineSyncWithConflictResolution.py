#!/usr/bin/env python3

"""
# Offline Sync with Conflict Resolution (Conceptual Example)

This script provides a conceptual example of how offline data synchronization
with conflict resolution could be implemented between a client device and a server.
It is simplified to illustrate the core concepts rather than providing a production-ready solution.

Key concepts demonstrated:
- Local data changes tracked when offline.
- Synchronization triggered when online.
- Server-side conflict detection.
- A simplified conflict resolution strategy (Last Write Wins).
- Client-side reconciliation after sync.
"""

import uuid
import datetime
import json
from typing import Dict, Any, List, Optional

# --- Conceptual Data Structures ---

class SyncedItem:
    """
    Represents an item that can be synced. Includes a version/timestamp for conflict detection.
    """
    def __init__(self, item_id: str, data: Dict[str, Any], version: datetime.datetime):
        self.item_id = item_id
        self.data = data
        self.version = version

    def to_dict(self) -> Dict[str, Any]:
        return {
            "item_id": self.item_id,
            "data": self.data,
            "version": self.version.isoformat()
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "SyncedItem":
        return cls(
            item_id=data["item_id"],
            data=data["data"],
            version=datetime.datetime.fromisoformat(data["version"])
        )

class LocalChange:
    """
    Represents a change made locally while potentially offline.
    """
    def __init__(self, item_id: str, change_type: str, data: Dict[str, Any], timestamp: datetime.datetime):
        # change_type: "create", "update", "delete"
        self.item_id = item_id
        self.change_type = change_type
        self.data = data # Data after change (for create/update), or minimal info (for delete)
        self.timestamp = timestamp # When the change was made locally

    def to_dict(self) -> Dict[str, Any]:
        return {
            "item_id": self.item_id,
            "change_type": self.change_type,
            "data": self.data,
            "timestamp": self.timestamp.isoformat()
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "LocalChange":
        return cls(
            item_id=data["item_id"],
            change_type=data["change_type"],
            data=data["data"],
            timestamp=datetime.datetime.fromisoformat(data["timestamp"])
        )

class SyncRequest:
    """
    Represents a request sent from the client to the server during sync.
    """
    def __init__(self, local_changes: List[LocalChange]):
        self.local_changes = local_changes

    def to_dict(self) -> Dict[str, Any]:
        return {
            "local_changes": [change.to_dict() for change in self.local_changes]
        }

class SyncConflict:
    """
    Represents a conflict detected during sync.
    """
    def __init__(self, item_id: str, local_change: LocalChange, server_change: SyncedItem):
        self.item_id = item_id
        self.local_change = local_change
        self.server_change = server_change

    def to_dict(self) -> Dict[str, Any]:
        return {
            "item_id": self.item_id,
            "local_change": self.local_change.to_dict(),
            "server_change": self.server_change.to_dict()
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "SyncConflict":
        return cls(
            item_id=data["item_id"],
            local_change=LocalChange.from_dict(data["local_change"]),
            server_change=SyncedItem.from_dict(data["server_change"])
        )

# --- Server Side ---

class Server:
    def __init__(self):
        self.remote_data = {}

    def process_sync_request(self, sync_request: SyncRequest) -> Tuple[List[SyncedItem], List[SyncConflict]]:
        resolved_changes = []
        conflicts = []
        for change in sync_request.local_changes:
            if change.change_type == "create":
                self.remote_data[change.item_id] = SyncedItem(change.item_id, change.data, change.timestamp)
                resolved_changes.append(self.remote_data[change.item_id])
            elif change.change_type == "update":
                if change.item_id in self.remote_data:
                    self.remote_data[change.item_id].data = change.data
                    self.remote_data[change.item_id].version = change.timestamp
                    resolved_changes.append(self.remote_data[change.item_id])
                else:
                    conflicts.append(SyncConflict(change.item_id, change, None))
            elif change.change_type == "delete":
                if change.item_id in self.remote_data:
                    del self.remote_data[change.item_id]
                else:
                    conflicts.append(SyncConflict(change.item_id, change, None))
        return resolved_changes, conflicts

    def resolve_conflict_last_write_wins(self, conflict: SyncConflict) -> SyncedItem:
        if conflict.local_change.change_type == "create":
            return conflict.local_change.data
        elif conflict.local_change.change_type == "update":
            return conflict.local_change.data
        elif conflict.local_change.change_type == "delete":
            return None

# --- Client Side ---

class Client:
    def __init__(self):
        self.local_data = {}

    def reconcile_after_sync(self, sync_response_data: Dict[str, Any]):
        for item_data in sync_response_data["updated_items"]:
            item = SyncedItem.from_dict(item_data)
            self.local_data[item.item_id] = item

# --- Main Function ---

def run_conceptual_sync_example():
    # Initialize server and client
    server = Server()
    client = Client()

    # Generate some initial data
    server.remote_data = {
        "item1": SyncedItem("item1", {"key1": "value1"}, datetime.datetime.now()),
        "item2": SyncedItem("item2", {"key2": "value2"}, datetime.datetime.now())
    }

    # Simulate local changes
    local_changes = [
        LocalChange("item1", "update", {"key1": "updatedValue1"}, datetime.datetime.now()),
        LocalChange("item3", "create", {"key3": "value3"}, datetime.datetime.now()),
        LocalChange("item2", "delete", None, datetime.datetime.now())
    ]

    # Create sync request
    sync_request = SyncRequest(local_changes)

    # --- Server Side --- #

    print("\n--- Server Side ---")

    # Apply changes and detect conflicts
    resolved_changes, conflicts = server.process_sync_request(sync_request)

    print(f"Server processed {len(resolved_changes)} changes, detected {len(conflicts)} conflicts.")

    # --- Conflict Resolution (Server Side) ---
    resolved_conflicts_details = []
    if conflicts:
        print("\nResolving Conflicts...")
        for conflict in conflicts:
            print(f"  Conflict on Item ID: {conflict.item_id}")
            # Example: Last Write Wins strategy
            resolved_item = server.resolve_conflict_last_write_wins(conflict)
            resolved_conflicts_details.append({
                "item_id": conflict.item_id,
                "resolution": "Last Write Wins",
                "final_version_source": "Client" if resolved_item.version == conflict.local_change.timestamp else "Server"
            })
            # The server's data is updated by resolve_conflict methods

    # --- Server Prepares Response ---
    # In a real system, the server would determine what data the client needs
    # (e.g., all items modified since client's last sync timestamp).
    # For simplicity, this example just returns all server data and conflict info.
    sync_response_data = {
        "updated_items": [item.to_dict() for item in server.remote_data.values()],
        "conflicts": resolved_conflicts_details,
        "status": "Success" if not conflicts else "SuccessWithConflicts"
    }
    print("\nServer preparing sync response.")

    # --- Client Side Reconciliation --- #

    print("\n--- Client Side Reconciliation ---")
    client.reconcile_after_sync(sync_response_data)

    print("\n--- Final State ---")
    print("Client Local Data after Sync:")
    for item in client.local_data.values():
        print(f"  ID: {item.item_id}, Data: {item.data}, Version: {item.version.strftime('%Y-%m-%d %H:%M:%S')}")

    print("Server Remote Data after Sync:")
    for item in server.remote_data.values():
        print(f"  ID: {item.item_id}, Data: {item.data}, Version: {item.version.strftime('%Y-%m-%d %H:%M:%S')}")

    print("\nOffline Sync Example Complete.")

if __name__ == "__main__":
    run_conceptual_sync_example() 