// This is an Unreal Script
class X2Ability_KeheckSittingDuck extends X2Ability;

static function array<X2DataTemplate> CreateTemplates() {
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Passive('KeheckSittingDuck', new class'X2Effect_KeheckSittingDuck'));
	return Templates;
}

static function X2AbilityTemplate Passive(name DataName, optional X2Effect Effect = none) {
	local X2AbilityTemplate Template;
	local X2Effect_Persistent PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_standard";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	PersistentEffect = X2Effect_Persistent(Effect);

	PersistentEffect.BuildPersistentEffect(1, true, false, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,,Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bCrossClassEligible = true;
	
	Template.bHideOnClassUnlock = true;
	Template.bDontDisplayInAbilitySummary = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	return Template;
}