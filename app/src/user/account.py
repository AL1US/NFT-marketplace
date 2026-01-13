from src.blockchain.client import contract_client
from flask import Blueprint, render_template, request, session, jsonify, url_for, redirect, flash

user_app = Blueprint("user", __name__)

@user_app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        
        data = request.get_json()
        public_key = data.get('public_key')
        
        if not public_key:
            return jsonify({'error': 'Нет публичного ключа'}), 400
        
        try:
            contract_client.set_account(public_key)
            session['public_key'] = contract_client.public_key
            
            return jsonify({
                'success': True,
                'redirect': url_for('profile.profile')
            })
            
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    return render_template("auth.html")

@user_app.route("/logout")
def logout():
    contract_client.unset_account()
    session.pop('public_key', None)
    return redirect(url_for("index"))

@user_app.route("/approve", methods=['GET', 'POST'])
def approve():
    
    if "public_key" not in session:
        flash('Сначала войди в систему', 'error')
        return redirect("/login")
    
    public_key = session["public_key"]
    
    contract_client.set_account(public_key)
    
    try:
        contract_client.approve_nft_contract()
        return redirect("/")
        
    except Exception as e:
        flash({'error': str(e)}), 500
        
    return render_template("profile.html")
