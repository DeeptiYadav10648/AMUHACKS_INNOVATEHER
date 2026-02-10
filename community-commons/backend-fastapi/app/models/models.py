from sqlalchemy import Column, Integer, String, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from ..db.base import Base


class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)


class PlayerProfile(Base):
    __tablename__ = 'player_profiles'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    background = Column(String)
    avatar = Column(String, nullable=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    civic_scores = relationship('CivicScore', back_populates='player')
    decisions = relationship('DecisionHistory', back_populates='player')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'background': self.background,
            'avatar': self.avatar,
        }


class Scenario(Base):
    __tablename__ = 'scenarios'
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    environment = Column(String)
    description = Column(Text)
    choices = relationship('Choice', back_populates='scenario')
    unlock_score = Column(Integer, default=0)


class Choice(Base):
    __tablename__ = 'choices'
    id = Column(Integer, primary_key=True, index=True)
    scenario_id = Column(Integer, ForeignKey('scenarios.id'))
    text = Column(String)
    # effect is JSON like {"community_harmony": 5, "personal_integrity": -1, "social_capital": 2}
    effect = Column(JSON)
    scenario = relationship('Scenario', back_populates='choices')

    def to_dict(self):
        return {
            'id': self.id,
            'scenario_id': self.scenario_id,
            'text': self.text,
            'effect': self.effect,
        }


class DecisionHistory(Base):
    __tablename__ = 'decisions_history'
    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(Integer, ForeignKey('player_profiles.id'))
    scenario_id = Column(Integer, ForeignKey('scenarios.id'))
    choice_id = Column(Integer, ForeignKey('choices.id'))
    note = Column(Text, nullable=True)
    player = relationship('PlayerProfile', back_populates='decisions')

    def to_dict(self):
        return {
            'id': self.id,
            'player_id': self.player_id,
            'scenario_id': self.scenario_id,
            'choice_id': self.choice_id,
            'note': self.note,
        }


class CivicScore(Base):
    __tablename__ = 'civic_scores'
    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(Integer, ForeignKey('player_profiles.id'))
    community_harmony = Column(Integer, default=0)
    personal_integrity = Column(Integer, default=0)
    social_capital = Column(Integer, default=0)
    player = relationship('PlayerProfile', back_populates='civic_scores')

    def to_dict(self):
        return {
            'id': self.id,
            'player_id': self.player_id,
            'community_harmony': self.community_harmony,
            'personal_integrity': self.personal_integrity,
            'social_capital': self.social_capital,
        }


class Badge(Base):
    __tablename__ = 'badges'
    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(Integer, ForeignKey('player_profiles.id'))
    name = Column(String)
    description = Column(String)


class NPC(Base):
    __tablename__ = 'npcs'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    role = Column(String)


class NPCRelationship(Base):
    __tablename__ = 'npc_relationships'
    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(Integer, ForeignKey('player_profiles.id'))
    npc_id = Column(Integer, ForeignKey('npcs.id'))
    relationship_score = Column(Integer, default=0)
    note = Column(Text, nullable=True)


class EnvironmentState(Base):
    __tablename__ = 'environment_state'
    id = Column(Integer, primary_key=True, index=True)
    scenario_id = Column(Integer, ForeignKey('scenarios.id'))
    state = Column(JSON, default={})
