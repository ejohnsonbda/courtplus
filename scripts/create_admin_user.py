"""
CourtPlus — Create Admin User Script
Usage: python3 scripts/create_admin_user.py

Creates a Supabase auth user and grants admin role.
Requires SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables.
"""

import os
import sys
import requests
import json

SUPABASE_URL = os.environ.get('SUPABASE_URL', 'YOUR_SUPABASE_URL')
SERVICE_KEY = os.environ.get('SUPABASE_SERVICE_KEY', 'YOUR_SERVICE_ROLE_KEY')

def create_admin(email, password):
    headers = {
        'apikey': SERVICE_KEY,
        'Authorization': f'Bearer {SERVICE_KEY}',
        'Content-Type': 'application/json'
    }

    # Create auth user
    resp = requests.post(
        f'{SUPABASE_URL}/auth/v1/admin/users',
        headers=headers,
        json={'email': email, 'password': password, 'email_confirm': True}
    )
    if resp.status_code not in (200, 201):
        print(f'Error creating user: {resp.text}')
        sys.exit(1)

    user_id = resp.json()['id']
    print(f'Created user: {email} (ID: {user_id})')

    # Grant admin role
    resp2 = requests.post(
        f'{SUPABASE_URL}/rest/v1/admin_roles',
        headers={**headers, 'Prefer': 'return=representation'},
        json={'user_id': user_id, 'role': 'admin'}
    )
    if resp2.status_code in (200, 201):
        print(f'Admin role granted successfully.')
    else:
        print(f'Warning: Could not grant admin role: {resp2.text}')

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: python3 create_admin_user.py <email> <password>')
        sys.exit(1)
    create_admin(sys.argv[1], sys.argv[2])
