from sqlalchemy.orm import Session
from ..models import models


def list_scenarios(db: Session):
    # Simple seed on first call if none exist
    if db.query(models.Scenario).count() == 0:
        seed_scenarios(db)
    return db.query(models.Scenario).all()


def get_scenario(db: Session, scenario_id: int):
    """Get a specific scenario by ID"""
    return db.query(models.Scenario).filter(models.Scenario.id == scenario_id).first()


def seed_scenarios(db: Session):
    s1 = models.Scenario(title='Missed Fare Dilemma', environment='Public Transit', description='You see someone trying to board without fare.', unlock_score=0)
    s2 = models.Scenario(title='Noise Complaint', environment='Residential Area', description='Loud party in a neighborhood late at night.', unlock_score=10)
    s3 = models.Scenario(title='Park Litter', environment='Public Park', description='You find litter left near a bench.', unlock_score=0)
    db.add_all([s1, s2, s3])
    # flush to populate `id` on new objects without committing/expiring
    db.flush()
    # add choices referencing the newly created scenario ids
    c1 = models.Choice(scenario_id=s1.id, text='Ignore and let them board', effect={"community_harmony": -2, "personal_integrity": -1, "social_capital": -1})
    c2 = models.Choice(scenario_id=s1.id, text='Alert the driver', effect={"community_harmony": 1, "personal_integrity": 1, "social_capital": -1})
    c3 = models.Choice(scenario_id=s1.id, text='Offer to buy a ticket', effect={"community_harmony": 3, "personal_integrity": 2, "social_capital": 2})
    c4 = models.Choice(scenario_id=s3.id, text='Pick up the litter', effect={"community_harmony": 2, "personal_integrity": 1, "social_capital": 1})
    c5 = models.Choice(scenario_id=s3.id, text='Walk away', effect={"community_harmony": -1, "personal_integrity": -1, "social_capital": -1})
    db.add_all([c1, c2, c3, c4, c5])
    db.commit()


def apply_decision(db: Session, scenario_id: int, payload):
    player = db.query(models.PlayerProfile).filter(models.PlayerProfile.id == payload.player_id).first()
    if not player:
        raise Exception('Player not found')
    choice = db.query(models.Choice).filter(models.Choice.id == payload.choice_id, models.Choice.scenario_id == scenario_id).first()
    if not choice:
        raise Exception('Choice not found')

    # record decision
    dec = models.DecisionHistory(player_id=player.id, scenario_id=scenario_id, choice_id=choice.id)
    db.add(dec)

    # update civic score (pick first score row)
    score = db.query(models.CivicScore).filter(models.CivicScore.player_id == player.id).first()
    if not score:
        score = models.CivicScore(player_id=player.id)
        db.add(score)

    eff = choice.effect or {}
    score.community_harmony += eff.get('community_harmony', 0)
    score.personal_integrity += eff.get('personal_integrity', 0)
    score.social_capital += eff.get('social_capital', 0)

    db.commit()
    db.refresh(score)

    # Determine environment status based on harmony score
    harmony = score.community_harmony
    if harmony >= 10:
        env_status = "Thriving"
    elif harmony >= 0:
        env_status = "Calm"
    else:
        env_status = "Tense"

    # NPC reaction message based on effect
    eff_sum = eff.get('community_harmony', 0) + eff.get('personal_integrity', 0) + eff.get('social_capital', 0)
    if eff_sum >= 5:
        npc_msg = 'Your neighbor appreciated your thoughtful approach.'
    elif eff_sum >= 2:
        npc_msg = 'The community took notice of your action.'
    elif eff_sum <= -3:
        npc_msg = 'The situation worsened from your choice.'
    else:
        npc_msg = 'The community responded with indifference.'

    # Gather all alternative choices for review
    all_choices = db.query(models.Choice).filter(
        models.Choice.scenario_id == scenario_id
    ).all()
    alternatives = [
        {
            'id': c.id,
            'text': c.text,
            'effect': c.effect or {},
            'is_chosen': c.id == choice.id
        }
        for c in all_choices
    ]

    return {
        'decision_id': dec.id,
        'chosen_text': choice.text,
        'chosen_effect': eff,
        'updated_scores': {
            'community_harmony': score.community_harmony,
            'personal_integrity': score.personal_integrity,
            'social_capital': score.social_capital,
        },
        'environment_status': env_status,
        'npc_message': npc_msg,
        'alternatives': alternatives
    }
