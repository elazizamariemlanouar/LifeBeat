

import firebase_admin
from firebase_admin import credentials


_firebase_app = None


def init_firebase(config) -> "firebase_admin.App":
    """Initialise l'application Firebase si ce n'est pas déjà fait.

    Args:
        config: objet de configuration Flask (voir app.config.Config)

    Returns:
        L'instance de l'application Firebase.
    """
    global _firebase_app

    if _firebase_app is not None:
        return _firebase_app

    if not firebase_admin._apps:
        cred = credentials.Certificate(config["FIREBASE_CREDENTIALS_PATH"])
        _firebase_app = firebase_admin.initialize_app(
            cred, {"databaseURL": config["FIREBASE_DATABASE_URL"]}
        )
    else:
        _firebase_app = firebase_admin.get_app()

    return _firebase_app
