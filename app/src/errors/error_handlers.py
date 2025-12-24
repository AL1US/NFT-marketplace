from flask import render_template, redirect, Blueprint

error_app = Blueprint("error", __name__)


@error_app.errorhandler(404)
def pageNotFount(error):
  return render_template('page404.html')