function generateStage()
{
	PlayState.defaultCamZoom = 0.65;
	spawnGirlfriend(false);

	var stageDir:String = 'stages/too-slow/images';

	var sky:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('BGSky', stageDir));
	sky.setGraphicSize(Std.int(sky.width * 1.4));
	add(sky);

	var midTrees1:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('TreesMidBack', stageDir));
	midTrees1.scrollFactor.set(0.7, 0.7);
	midTrees1.setGraphicSize(Std.int(midTrees1.width * 1.4));
	add(midTrees1);

	var treesmid:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('TreesMid', stageDir));
	treesmid.scrollFactor.set(0.7, 0.7);
	treesmid.setGraphicSize(Std.int(treesmid.width * 1.4));
	add(treesmid);

	var treesoutermid:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('TreesOuterMid1', stageDir));
	treesoutermid.scrollFactor.set(0.7, 0.7);
	treesoutermid.setGraphicSize(Std.int(treesoutermid.width * 1.4));
	add(treesoutermid);

	var treesoutermid2:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('TreesOuterMid2', stageDir));
	treesoutermid2.scrollFactor.set(0.7, 0.7);
	treesoutermid2.setGraphicSize(Std.int(treesoutermid2.width * 1.4));
	add(treesoutermid2);

	var lefttrees:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('TreesLeft', stageDir));
	lefttrees.scrollFactor.set(0.7, 0.7);
	lefttrees.setGraphicSize(Std.int(lefttrees.width * 1.4));
	add(lefttrees);

	var righttrees:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('TreesRight', stageDir));
	righttrees.scrollFactor.set(0.7, 0.7);
	righttrees.setGraphicSize(Std.int(righttrees.width * 1.4));
	add(righttrees);

	var outerbush:FNFSprite = new FNFSprite(-600, -150).loadGraphic(Paths.image('OuterBush', stageDir));
	outerbush.setGraphicSize(Std.int(outerbush.width * 1.4));
	add(outerbush);

	var outerbush2:FNFSprite = new FNFSprite(-600, -150).loadGraphic(Paths.image('OuterBushUp', stageDir));
	outerbush2.setGraphicSize(Std.int(outerbush2.width * 1.4));
	add(outerbush2);

	var grass:FNFSprite = new FNFSprite(-600, -150).loadGraphic(Paths.image('Grass', stageDir));
	grass.setGraphicSize(Std.int(grass.width * 1.4));
	add(grass);

	var deadegg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('DeadEgg', stageDir));
	deadegg.setGraphicSize(Std.int(deadegg.width * 1.4));
	add(deadegg);

	var deadknux:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('DeadKnux', stageDir));
	deadknux.setGraphicSize(Std.int(deadknux.width * 1.4));
	add(deadknux);

	var deadtailz:FNFSprite = new FNFSprite(-700, -200).loadGraphic(Paths.image('DeadTailz', stageDir));
	deadtailz.setGraphicSize(Std.int(deadtailz.width * 1.4));
	add(deadtailz);

	var deadtailz1:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('DeadTailz1', stageDir));
	deadtailz1.setGraphicSize(Std.int(deadtailz1.width * 1.4));
	add(deadtailz1);

	var deadtailz2:FNFSprite = new FNFSprite(-600, -400).loadGraphic(Paths.image('DeadTailz2', stageDir));
	deadtailz2.setGraphicSize(Std.int(deadtailz2.width * 1.4));
	add(deadtailz2);
}

function repositionPlayers(boyfriend:Character, gf:Character, dad:Character)
{
	dad.x -= 300;
	dad.y -= 50;
	boyfriend.x -= 80;
	boyfriend.y -= 600;
}
