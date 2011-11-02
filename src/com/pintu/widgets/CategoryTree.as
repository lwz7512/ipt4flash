package com.pintu.widgets
{
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.sibirjak.asdpc.listview.renderer.ListItemContent;
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.treeview.TreeView;
	import com.sibirjak.asdpc.treeview.renderer.TreeNodeRenderer;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class CategoryTree extends Sprite{
		
		//缩略图
		public static const CATEGORY_GALLERY_TBMODE:String = "gallery_tb";
		//大图
		public static const CATEGORY_GALLERY_BPMODE:String = "gallery_bp";
		public static const CATEGORY_HOT:String = "hot";
		public static const CATEGORY_CLASSICAL:String = "classical";
		public static const CATEGORY_FAVORED:String = "favored";
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		private var leftColumnHeight:Number;
		
		private var browseTree:TreeView;
		private var tagsTree:TreeView;
		
		private var browseTreeX:Number;
		private var browseTreeY:Number;
		private var browseTreeHeight:Number = InitParams.LEFTCOLUMN_HEIGHT;
		private var tagsTreeX:Number;
		private var tagsTreeY:Number;
		private var treeVerticalGap:Number = 4;
		
		private var browseTreeXML:XML;
		
		
		private var _browseType:String;
		
		public function CategoryTree(){
			super();
			_browseType = CATEGORY_GALLERY_TBMODE;
			
			initVisualPartsPos();
			
			browseTreeXML = new XML(
				<item name="浏览">
					<item name="画廊缩略图" type="gallery_tb"/>
					<item name="画廊大图" type="gallery_bp"/>
					<item name="热点图片" type="hot"/>
					<item name="经典图片" type="classical"/>
					<item name="最近被收藏" type="favored"/>
				</item>
			);
			
			drawLeftCategoryBackground();
			
			createBrowseTree();
			
			//TODO, LOADING TAGS...
			
			//FIXME ,  应该统一成一颗树
//			buildTagsTree();
		}
		
		public function get browseType():String{
			return _browseType;
		}
		
		
		private function initVisualPartsPos():void{
			drawStartX = InitParams.startDrawingX();
			drawStartY = InitParams.HEADERFOOTER_HEIGHT
				+InitParams.TOP_BOTTOM_GAP
				+InitParams.MAINMENUBAR_HEIGHT
				+InitParams.DEFAULT_GAP;
			
			browseTreeX = drawStartX+2;
			browseTreeY = drawStartY+2;
			tagsTreeX = browseTreeX;
			tagsTreeY = browseTreeY+browseTreeHeight+treeVerticalGap;
			
			leftColumnHeight = InitParams.LEFTCOLUMN_HEIGHT;			
			if(InitParams.isStretchHeight()){
				leftColumnHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.HEADERFOOTER_HEIGHT;
			}
		}
		
		private function drawLeftCategoryBackground():void{
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,
				InitParams.LEFTCOLUMN_WIDTH,leftColumnHeight);
			this.graphics.endFill();
		}
		
		private function createBrowseTree():void{
			browseTree = new TreeView();
			browseTree.dataSource = browseTreeXML;			
			browseTree.setSize(InitParams.LEFTCOLUMN_WIDTH-2,browseTreeHeight);
			browseTree.x = browseTreeX;
			browseTree.y = browseTreeY;
			browseTree.selectItemAt(1);
			addStyleForTree(browseTree);
			//TODO, ADD CHANGE EVENT LISTENER...
			
			this.addChild(browseTree);												
		}
		
		private function addStyleForTree(tree:TreeView):void{
			tree.setStyle(TreeView.style.showRoot,true);
			tree.setStyle(TreeView.style.maxExpandAllLevel,2);
			tree.setStyle(TreeNodeRenderer.style.connectors,false);
			tree.setStyle(TreeNodeRenderer.style.disclosureButton,false);
			//文字大小
			tree.setStyle(ListItemContent.style.labelStyles,[Label.style.size, 12]);
			//文字颜色
			tree.setStyle(ListItemContent.style.labelStyles,
				[Label.style.size, 12,Label.style.color, 0x444444]);
			tree.setStyle(ListItemContent.style.overLabelStyles,
				[Label.style.size, 12,Label.style.color, 0x444444]);
			tree.setStyle(ListItemContent.style.selectedLabelStyles,
				[Label.style.size, 12,Label.style.color, 0xFFFFFF]);
			//默认展开第一级
			tree.expandNodeAt(0);			
		}
		
		private function buildTagsTree():void{
			var tagData : Node = new Node("分类","");
			//TODO, ADD DATA AT RUNTIME FROM BACKEND...
			tagData.addNode(new Node("tag_1","id_1"));
			tagData.addNode(new Node("tag_2","id_2"));
			tagData.addNode(new Node("tag_3","id_3"));
			
			tagsTree = new TreeView();
			tagsTree.dataSource = tagData;
			tagsTree.setSize(InitParams.LEFTCOLUMN_WIDTH-2,
				InitParams.LEFTCOLUMN_HEIGHT-browseTreeHeight-treeVerticalGap);
			tagsTree.x = tagsTreeX;
			tagsTree.y = tagsTreeY;
			addStyleForTree(tagsTree);
			//TODO, ADD CHANGE EVENT LISTENER...
			
			this.addChild(tagsTree);	
		}
		
		
	}
}

import org.as3commons.collections.framework.IDataProvider;

internal class Node implements IDataProvider {
	private var _name : String;
	private var _id:String;
	private var _childNodes : Array = new Array();
	
	public function Node(name : String, id:String) {
		_name = name;
		_id = id;
	}
	
	public function addNode(node : Node) : void {
		_childNodes.push(node);
	}
	
	public function itemAt(index : uint) : * {
		return _childNodes[index];
	}
	
	public function get size() : uint {
		return _childNodes.length;
	}
	
	public function get name() : String {
		return _name;
	}
}