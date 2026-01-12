from flask import session, redirect
ALL_METHODS = ["GET", "POST"]

def check_session():
    if "pk" not in session:
        return redirect("/login")