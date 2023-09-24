// This is an Unreal Script
class X2Effect_KeheckSittingDuck extends X2Effect_Persistent config(SittingDucks);

var config int DISORIENT_BONUS;
var config int STUN_BONUS;
var config int MC_BONUS;

var config int DISORIENT_CRIT;
var config int STUN_CRIT;
var config int MC_CRIT;

var config float DISORIENT_DEF_PENALTY;
var config float STUN_DEF_PENALTY;
var config float MC_DEF_PENALTY;

var config float DISORIENT_AMPLIFICATION;
var config float STUN_AMPLIFICATION;

var config bool B_SACRIFICE_PAWN;
var config bool B_AMPLIFY_ANGLES;
var config bool B_MINDCONTROL_IGNORES_COVER;
var config bool B_REQUIRES_FLANKED;

var config int STUN_DODGE_PENALTY;
var config int DISORIENT_DODGE_PENALTY;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers) {
	local ShotModifierInfo ShotInfo;
	local ShotModifierInfo ShotCrit;
	local GameRulesCache_VisibilityInfo VisInfo;
	local int i;
	local int HighCoverBonus;
	local int LowCoverBonus;
	local float AngleMod;

	AngleMod = 0;

	HighCoverBonus = class'X2AbilityToHitCalc_StandardAim'.default.HIGH_COVER_BONUS;
	LowCoverBonus = class'X2AbilityToHitCalc_StandardAim'.default.LOW_COVER_BONUS;

	X2TacticalGameRuleset(XComGameInfo(class'Engine'.static.GetCurrentWorldInfo().Game).GameRuleset).VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, Target.ObjectID, VisInfo);

	if(!B_REQUIRES_FLANKED || VisInfo.TargetCover == CT_None)
		AngleMod = 1;
	else if(VisInfo.TargetCover != CT_None && B_AMPLIFY_ANGLES && VisInfo.TargetCoverAngle < class'X2AbilityToHitCalc_StandardAim'.default.MAX_ANGLE_TO_COVER)
		AngleMod = 1-FClamp((VisInfo.TargetCoverAngle - class'X2AbilityToHitCalc_StandardAim'.default.MIN_ANGLE_TO_COVER) / (class'X2AbilityToHitCalc_StandardAim'.default.MAX_ANGLE_TO_COVER - class'X2AbilityToHitCalc_StandardAim'.default.MIN_ANGLE_TO_COVER), 0.0, 1.0);

	if(AngleMod == 0)
		return;

	// Sitting Ducks are determined in this order:
	// 1) Mind Control
	// 2) Stunned
	// 3) Disoriented
	// If one of these afflictions is found, its effects are applied and the function ends
	// MC'd Units should only be defenceless against the team that's mind controlling them
	if(Target.AffectedByEffectNames.Find(class'X2Effect_MindControl'.default.EffectName) != INDEX_NONE && (Attacker.IsFriendlyUnit(Target) || B_SACRIFICE_PAWN)) {
		ShotInfo.ModType = eHit_Success;
		if(B_MINDCONTROL_IGNORES_COVER && VisInfo.TargetCover != CT_None) {
			AngleMod = 1;
			if(VisInfo.TargetCover == CT_Standing) ShotInfo.Value = HighCoverBonus;
			if(VisInfo.TargetCover == CT_MidLevel) ShotInfo.Value = LowCoverBonus;
		}
		ShotInfo.Value += MC_BONUS * AngleMod + Target.GetCurrentStat(eStat_Defense) * MC_DEF_PENALTY;
		ShotInfo.Reason = class'X2StatusEffects'.default.MindControlFriendlyName;
		ShotModifiers.AddItem(ShotInfo);

		ShotCrit.ModType = eHit_Crit;
		ShotCrit.Value = MC_CRIT;
		ShotCrit.Reason = class'X2StatusEffects'.default.MindControlFriendlyName;
		ShotModifiers.AddItem(ShotCrit);
	}
	else if(Target.AffectedByEffectNames.Find(class'X2AbilityTemplateManager'.default.StunnedName) != INDEX_NONE) {
		ShotInfo.ModType = eHit_Success;
		ShotInfo.Value = STUN_BONUS * AngleMod + Target.GetCurrentStat(eStat_Defense) * DISORIENT_DEF_PENALTY;
		ShotInfo.Reason = class'X2StatusEffects'.default.StunnedFriendlyName;
		ShotModifiers.AddItem(ShotInfo);

		ShotCrit.ModType = eHit_Crit;
		ShotCrit.Value = STUN_CRIT;
		ShotCrit.Reason = class'X2StatusEffects'.default.StunnedFriendlyName;
		ShotModifiers.AddItem(ShotCrit);
	}
	else if(Target.AffectedByEffectNames.Find(class'X2AbilityTemplateManager'.default.DisorientedName) != INDEX_NONE) {
		ShotInfo.ModType = eHit_Success;
		ShotInfo.Value = DISORIENT_BONUS * AngleMod + Target.GetCurrentStat(eStat_Defense) * STUN_DEF_PENALTY;
		ShotInfo.Reason = class'X2StatusEffects'.default.DisorientedFriendlyName;
		ShotModifiers.AddItem(ShotInfo);

		ShotCrit.ModType = eHit_Crit;
		ShotCrit.Value = DISORIENT_CRIT;
		ShotCrit.Reason = class'X2StatusEffects'.default.DisorientedFriendlyName;
		ShotModifiers.AddItem(ShotCrit);
	}
}