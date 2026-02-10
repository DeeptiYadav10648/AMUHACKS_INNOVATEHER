from pydantic import BaseModel
from typing import Optional, List, Dict


class PlayerProfileBase(BaseModel):
    name: str
    background: Optional[str]
    avatar: Optional[str]


class PlayerProfileCreate(PlayerProfileBase):
    pass


class CivicScore(BaseModel):
    community_harmony: int
    personal_integrity: int
    social_capital: int


class PlayerProfileRead(PlayerProfileBase):
    id: int
    civic_scores: List[Dict] = []

    class Config:
        orm_mode = True


class ScenarioRead(BaseModel):
    id: int
    title: str
    environment: str
    description: str
    choices: List[Dict]

    class Config:
        orm_mode = True


class DecisionCreate(BaseModel):
    player_id: int
    choice_id: int


class DecisionResult(BaseModel):
    player_id: int
    updated_scores: CivicScore
    message: str
    badges_awarded: Optional[List[Dict]] = []
    unlocked_scenarios: Optional[List[Dict]] = []


class PlayerProgress(BaseModel):
    player_id: int
    civic_scores: List[Dict]
