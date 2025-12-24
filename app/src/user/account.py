from src.blockchain.client import contract_client
from flask import Blueprint, Flask, redirect, render_template, request, session, jsonify

user_app = Blueprint("user", __name__)

@user_app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        
        data = request.get_json()
        pk = data.get('pk')
        
        if not pk:
            return jsonify({'error': 'Нет публичного ключа'}), 400
        
        try:
            contract_client.set_account(pk)
            session['pk'] = pk
            
            return jsonify({
                'success': True,
            })
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    return render_template("auth.html")
