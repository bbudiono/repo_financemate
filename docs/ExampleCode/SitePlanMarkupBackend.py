# SitePlanMarkupBackend.py
#
# This Python file demonstrates the backend components for the Collaborative Site Plan Markup feature.
# It handles storing site plans and annotations and managing real-time collaboration.
#
# Complexity: High - Involves API design, data storage for plans/annotations, and real-time communication (WebSockets).
# Aesthetics: Not applicable (backend code).
#
# Key Backend Components/Features:
# - API endpoints for uploading/fetching site plans.
# - API endpoints for fetching/saving annotations.
# - WebSocket server for real-time annotation updates and collaborator presence.
# - Data storage for site plan files and structured annotation data.
# - User authentication and authorization for plan and annotation access.
#
# Technologies used: Python with Flask/Django/FastAPI, WebSocket library (Flask-SocketIO, websockets),
# PostgreSQL/MongoDB, file storage (local or cloud).

from flask import Flask, request, jsonify, send_from_directory
from flask_socketio import SocketIO, emit
import os
import uuid # For generating UUIDs
# import database_library # Example: from some_db_library import Database
# import auth_library # Example: from some_auth_library import authenticate_user

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key_here' # TODO: Use a strong, randomly generated key from environment variables

# Initialize SocketIO
socketio = SocketIO(app, cors_allowed_origins="*") # TODO: Configure CORS appropriately for production

# Example: Initialize database (conceptual)
# db = Database()

# Example: Configuration for storing site plan files
SITE_PLANS_FOLDER = './site_plans' # TODO: Configure a secure and persistent storage location
if not os.path.exists(SITE_PLANS_FOLDER):
    os.makedirs(SITE_PLANS_FOLDER)

app.config['SITE_PLANS_FOLDER'] = SITE_PLANS_FOLDER

# MARK: - Data Storage (Conceptual - replace with database interaction)

# Example: In-memory data for demonstration
site_plans_data = [
    # {'id': str(uuid.uuid4()), 'name': 'Project Alpha Site Layout', 'filename': 'site_plan_alpha.png'}
]

annotations_data = [
    # {'id': str(uuid.uuid4()), 'planId': '<site_plan_id>', 'userId': '<user_id>', 'type': 'marker', 'x': 100, 'y': 150, 'color': 'red'}
]

# MARK: - Helper Functions (Conceptual)

def save_site_plan_metadata(plan_id, name, filename):
    # TODO: Save site plan metadata (id, name, filename) to database
    print(f"Saving site plan metadata: {plan_id}, {name}, {filename} (conceptual)")
    site_plans_data.append({'id': str(plan_id), 'name': name, 'filename': filename}) # Example in-memory

def get_site_plan_by_id(plan_id):
    # TODO: Fetch site plan metadata from database
    print(f"Fetching site plan metadata for ID: {plan_id} (conceptual)")
    return next((plan for plan in site_plans_data if plan['id'] == str(plan_id)), None) # Example in-memory

def get_annotations_by_plan_id(plan_id):
    # TODO: Fetch annotations for a plan from database
    print(f"Fetching annotations for plan ID: {plan_id} (conceptual)")
    return [ann for ann in annotations_data if ann['planId'] == str(plan_id)] # Example in-memory

def save_annotation(annotation_data):
    # TODO: Validate and save annotation to database
    print(f"Saving annotation: {annotation_data} (conceptual)")
    annotations_data.append(annotation_data) # Example in-memory

def update_annotation_in_db(annotation_id, updated_data):
    # TODO: Find and update annotation in database
    print(f"Updating annotation ID: {annotation_id} with {updated_data} (conceptual)")
    # Example in-memory update (simplified)
    # Check if the updated data contains an ID and if it matches the target annotation ID
    if 'id' in updated_data and str(annotation_id) == str(updated_data['id']):
         # Find the annotation in the in-memory list by ID
         for i, annotation in enumerate(annotations_data):
             if annotation.get('id') == str(annotation_id):
                 # Merge updated data into the existing annotation
                 for key, value in updated_data.items():
                     annotations_data[i][key] = value
                 break # Exit the loop once found and updated

def delete_annotation_from_db(annotation_id):
    # TODO: Delete annotation from database
    print(f"Deleting annotation ID: {annotation_id} (conceptual)")
    global annotations_data
    annotations_data = [ann for ann in annotations_data if ann['id'] != str(annotation_id)]

# MARK: - API Endpoints

@app.route('/api/siteplans', methods=['POST'])
def upload_site_plan():
    # Handle site plan image upload
    # TODO: Authenticate and authorize user

    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    if file:
        # TODO: Generate a secure filename and validate file type
        filename = file.filename # Example, use secure_filename in production
        plan_id = uuid.uuid4() # Generate a unique ID for the plan
        filepath = os.path.join(app.config['SITE_PLANS_FOLDER'], filename)
        file.save(filepath)

        # TODO: Extract plan name from form data or filename
        plan_name = request.form.get('name', filename) # Example

        # Save metadata to database
        save_site_plan_metadata(plan_id, plan_name, filename)

        return jsonify({"message": "Site plan uploaded successfully", "planId": str(plan_id), "name": plan_name, "filename": filename}), 201

    return jsonify({"error": "File upload failed"}), 500

@app.route('/api/siteplans/<plan_id>/image', methods=['GET'])
def get_site_plan_image(plan_id):
    # Serve site plan image by ID
    # TODO: Authenticate and authorize user access to this plan

    plan = get_site_plan_by_id(plan_id)

    if plan:
        try:
            return send_from_directory(app.config['SITE_PLANS_FOLDER'], plan['filename'])
        except FileNotFoundError:
            return jsonify({"error": "Site plan image not found on server"}), 404
    return jsonify({"error": "Site plan not found"}), 404

@app.route('/api/siteplans/<plan_id>/annotations', methods=['GET'])
def get_annotations(plan_id):
    # Fetch all annotations for a specific site plan
    # TODO: Authenticate and authorize user access to this plan
    return jsonify(get_annotations_by_plan_id(plan_id))

@app.route('/api/siteplans/<plan_id>/annotations', methods=['POST'])
def add_annotation_api(plan_id):
    # Add a new annotation via REST API (alternative/initial)
    # TODO: Authenticate and authorize user access to this plan

    if not request.json:
        return jsonify({"error": "Invalid data format"}), 400

    annotation_data = request.json
    # TODO: Validate annotation_data
    annotation_data['planId'] = str(plan_id)
    annotation_data['id'] = str(uuid.uuid4()) # Assign a unique ID
    # TODO: Assign userId from authenticated user

    save_annotation(annotation_data)

    # TODO: Broadcast the new annotation to connected clients via WebSocket
    # socketio.emit('new_annotation', annotation_data, room=str(plan_id))

    return jsonify({"message": "Annotation added", "annotationId": annotation_data['id']}), 201

# MARK: - WebSocket Events

@socketio.on('connect')
def handle_connect():
    print('Client connected', request.sid)
    # TODO: Authenticate user on connect if needed

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected', request.sid)
    # TODO: Handle collaborator leaving a room

@socketio.on('join_plan')
def handle_join_plan(data):
    # Client requests to join a specific site plan's collaboration room
    # data should contain 'planId' and 'userId'
    plan_id = data.get('planId')
    user_id = data.get('userId')
    if plan_id and user_id:
        # TODO: Authenticate and authorize user for this plan
        # if authenticate_user(...) and authorize_user(...):
        from flask_socketio import join_room, leave_room
        join_room(str(plan_id)) # Join a room specific to the plan ID
        print(f'User {user_id} joined room for plan {plan_id}')
        # TODO: Broadcast collaborator joining to others in the room
        # emit('collaborator_joined', {'userId': user_id}, room=str(plan_id))
    else:
        print('Invalid join_plan data received')

@socketio.on('leave_plan')
def handle_leave_plan(data):
    # Client requests to leave a collaboration room
    plan_id = data.get('planId')
    user_id = data.get('userId')
    if plan_id and user_id:
        from flask_socketio import leave_room
        leave_room(str(plan_id)) # Leave the room specific to the plan ID
        print(f'User {user_id} left room for plan {plan_id}')
        # TODO: Broadcast collaborator leaving to others in the room
        # emit('collaborator_left', {'userId': user_id}, room=str(plan_id))

@socketio.on('annotation_update')
def handle_annotation_update(data):
    # Client sends an update for an annotation (drawing, moving, editing)
    # data should contain the updated annotation object
    # TODO: Authenticate and authorize the user
    # TODO: Validate the update

    updated_annotation = data.get('annotation')
    if updated_annotation and 'planId' in updated_annotation:
        plan_id = updated_annotation['planId']
        # Save the update to the database
        # update_annotation_in_db(updated_annotation['id'], updated_annotation)
        print(f"Received annotation update for plan {plan_id}: {updated_annotation} (conceptual)")
        # Broadcast the update to all other clients in the same plan room
        # emit('annotation_updated', updated_annotation, room=str(plan_id), include_self=False) # include_self=False prevents sending back to the sender

    else:
        print('Invalid annotation_update data received')

@socketio.on('annotation_delete')
def handle_annotation_delete(data):
    # Client sends a request to delete an annotation
    # data should contain 'planId' and 'annotationId'
    # TODO: Authenticate and authorize the user

    plan_id = data.get('planId')
    annotation_id = data.get('annotationId')

    if plan_id and annotation_id:
        # Delete from database
        # delete_annotation_from_db(annotation_id)
        print(f"Received annotation delete request for plan {plan_id}, annotation {annotation_id} (conceptual)")
        # Broadcast the deletion to all other clients in the same plan room
        # emit('annotation_deleted', {'annotationId': annotation_id}, room=str(plan_id), include_self=False)
    else:
        print('Invalid annotation_delete data received')

# MARK: - Run App

if __name__ == '__main__':
    # Example: Run the Flask-SocketIO app. In production, use a more robust server.
    socketio.run(app, debug=True) # Set debug=False in production 