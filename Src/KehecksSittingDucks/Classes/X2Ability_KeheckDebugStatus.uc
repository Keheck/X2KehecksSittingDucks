// This is an Unreal Script
class X2Ability_KeheckDebugStatus extends X2Ability;

static function array<X2DataTemplate> CreateTemplates() {
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Active('KeheckDebugStun', class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false)));
	return Templates;
}

static function X2DataTemplate Active(name AbilityName, X2Effect effect) {
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints AP_Cost;
	local X2Condition_Visibility VisCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_confuse";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.Hostility = eHostility_Neutral;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	AP_Cost = new class'X2AbilityCost_ActionPoints';
	AP_Cost.iNumPoints = 1;
	AP_Cost.bFreeCost = true;
	Template.AbilityCosts.AddItem(AP_Cost);

	VisCondition = new class'X2Condition_Visibility';
	VisCondition.bRequireGameplayVisible = true;
	VisCondition.bActAsSquadsight = true;
	Template.AbilityTargetConditions.AddItem(VisCondition);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Single';
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AddTargetEffect(class'X2StatusEffects'.static.CreateStunnedStatusEffect(1, 100, false));

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.CustomFireAnim = 'HL_SignalPoint';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}