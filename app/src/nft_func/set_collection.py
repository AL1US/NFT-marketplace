from flask import render_template, redirect, session, Blueprint, request, jsonify, flash

from src.blockchain.client import contract_client

coll_app = Blueprint("coll", __name__)


@coll_app.route("/setCollection", methods=['GET', 'POST'])
def setCollection():
    if "public_key" not in session:
        return redirect("/login")
    
    contract_client.set_account(session["public_key"])

    if request.method == "POST":
        try:
            name_coll = request.form.get("name_coll")
            description = request.form.get("description")
            
            if not all([name_coll, description]):
                flash("Заполните все поля", "error")
                return render_template("setNFT.html")
            
            contract_client.to_transact(
                method_name="setCollection",
                args=[
                    name_coll,
                    description,
                ],
                is_transact=True
            )
            
            return redirect("/profile")
        
        except Exception as e:
            flash(str(e), "error")
    return render_template("setCollection.html")


@coll_app.route("/collection")
def collection():
    if "public_key" not in session:
        return redirect("/login")

    public_key = session["public_key"]
    
    collection = contract_client.to_transact(
        method_name="getAllStoreCollections"
    )
    
    return render_template(
        "collections.html",
        collection = collection
    )

@coll_app.route("/setCollectionInStore/<int:id>", methods=["POST"])
def setCollectionInStore(id):
    if "public_key" not in session:
        return redirect("/login")

    contract_client.set_account(session["public_key"])
    price_str = request.form.get("price")
    price = int(price_str)
    
    try:

        contract_client.to_transact(
            method_name="setCollectionInStore",
            args=[
                id,
                price
            ],
            is_transact=True
        ) 
        
    except Exception as e:
        flash(str(e), "error")
        return redirect("/collection")
    return redirect("/collection")


@coll_app.route("/buy_collection/<int:index>/<int:price>", methods=["POST"])
def buy_collection(index, price):
    if "public_key" not in session:
        return redirect("/login")
    
    contract_client.set_account(session["public_key"])
        
    try:
        
        contract_client.to_transact(
                method_name="buyCollection",
                args=[
                    index
                ],
                is_transact=True,
                value_wei=price
            )
    except Exception as e:
        flash(str(e), "error")
        
        return redirect("/profile")
    return redirect("/profile")

@coll_app.route("/setNFTInColl/<int:id>", methods=["POST"])
def setNFTInColl(id):
    if "public_key" not in session:
        return redirect("/login")
    
    contract_client.set_account(session["public_key"])
        
    try:
        id_coll_str = request.form.get("id_coll")
        amount_str= request.form.get("amount")
        amount = int(amount_str)
        id_coll = int(id_coll_str)
        
        contract_client.to_transact(
                method_name="setNFTInCollection",
                args=[
                    id_coll,
                    id,
                    amount
                ],
                is_transact=True,
            )
        
    except Exception as e:
        flash(str(e), "error")
        return redirect("/profile")
    return redirect("/profile")




