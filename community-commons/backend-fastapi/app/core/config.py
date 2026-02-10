import os

DATABASE_URL = os.getenv('DATABASE_URL') or 'sqlite:///./community_commons.db'
