package com.pintu.widgets
{
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	import com.sibirjak.asdpc.listview.ListItemEvent;
	import com.sibirjak.asdpc.listview.ListView;
	import com.sibirjak.asdpc.listview.renderer.ListItemContent;
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.treeview.TreeView;
	import com.sibirjak.asdpc.treeview.renderer.TreeNodeRenderer;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	[Event(name="browseChanged", type="com.pintu.events.PintuEvent")]
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
		
		private var browseTreeX:Number;
		private var browseTreeY:Number;
		private var browseTreeHeight:Number = InitParams.LEFTCOLUMN_HEIGHT;
		
		private var tagsTreeX:Number;
		private var tagsTreeY:Number;
		private var treeVerticalGap:Number = 4;
						
		private var _browseType:String;
		
		private var _model:IPintu;
		
		private var _rootNode:Node;
		
		private var _browseNodes:Node;
		
		private var _tagsListRendered:Boolean = false;
		
		private var _scrolledIndex:int = 0;
		
		
		public function CategoryTree(model:IPintu){
			super();
			this._model = model;
			_browseType = CATEGORY_GALLERY_TBMODE;
			_rootNode = new Node("root","0");
			
			initVisualPartsPos();						
			
			drawLeftCategoryBackground();
			
			createBrowseTree();
			
			this.addEventListener(MouseEvent.MOUSE_WHEEL, scrollTree);
			
			//TODO, LOADING TAGS...
			
		}
		
		private function scrollTree(event:MouseEvent):void{
			//如果标签加载完毕，而且有滚动条
			if(_tagsListRendered && browseTree.maxScrollIndex>0){
				//滚动一次，改变一次索引
				_scrolledIndex += event.delta;
				//不能小于最小
				if(_scrolledIndex<0){
					_scrolledIndex = 0;
					browseTree.scrollToItemAt(0);
				}
				//不能超过最大
				if(_scrolledIndex>browseTree.maxScrollIndex){
					_scrolledIndex = browseTree.maxScrollIndex;
					browseTree.scrollToItemAt(browseTree.maxScrollIndex);
				}
				//正常滚动
				browseTree.scrollToItemAt(_scrolledIndex);
			}
		}
		
		public function get browseType():String{
			return _browseType;
		}
		
		
		private function initVisualPartsPos():void{
			drawStartX = InitParams.startDrawingX();
			drawStartY = InitParams.HEADER_HEIGHT
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
					-InitParams.FOOTER_HEIGHT;
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
			_browseNodes = new Node("浏览", "1");
			_browseNodes.addNode(new Node("画廊缩略图", "gallery_tb"));
			_browseNodes.addNode(new Node("画廊大图", "gallery_bp"));
			_browseNodes.addNode(new Node("热点图片", "hot"));
			_browseNodes.addNode(new Node("经典图片", "classical"));
			_browseNodes.addNode(new Node("最近被收藏", "favored"));
			
			_rootNode.addNode(_browseNodes);
			
			browseTree = new TreeView();
			browseTree.dataSource = _rootNode;
			
			browseTree.setSize(InitParams.LEFTCOLUMN_WIDTH-2,browseTreeHeight);
			browseTree.setStyle(TreeView.style.itemSize, StyleParams.TREEITEM_HEIGHT);
			browseTree.x = browseTreeX;
			browseTree.y = browseTreeY;
			browseTree.selectItemAt(1);
			//默认展开第一级
			browseTree.expandNodeAt(0);	
			
			addStyleForTree(browseTree);
			
			browseTree.addEventListener(ListItemEvent.CLICK, switchBrowseType);
			
			this.addChild(browseTree);												
		}
		
		private function switchBrowseType(event:ListItemEvent):void{
			var node:Node = event.item as Node;
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, node.type);
			
			this.dispatchEvent(typeChangeEvent);
		}
		
		private function addStyleForTree(tree:TreeView):void{
			tree.setStyle(TreeView.style.showRoot,false);
			tree.setStyle(TreeView.style.maxExpandAllLevel,2);
			tree.setStyle(TreeNodeRenderer.style.connectors,false);
			tree.setStyle(TreeNodeRenderer.style.disclosureButton,false);
			//隐藏滚动条，用滚轮来移动列表
			tree.setStyle(ListView.style.scrollBarVisibility, false);
			
			//文字大小
			tree.setStyle(ListItemContent.style.labelStyles,[Label.style.size, 12]);
			//文字颜色
			tree.setStyle(ListItemContent.style.labelStyles,
				[Label.style.size, 12,Label.style.color, 0x444444]);
			tree.setStyle(ListItemContent.style.overLabelStyles,
				[Label.style.size, 12,Label.style.color, 0x444444]);
			tree.setStyle(ListItemContent.style.selectedLabelStyles,
				[Label.style.size, 12,Label.style.color, 0xFFFFFF]);			
			
		}
		
		//TODO, ADD DATA AT RUNTIME FROM BACKEND...
		private function buildTagsTree():void{
			var tagData : Node = new Node("分类","2");
			tagData.addNode(new Node("tag_1","id_1"));
			tagData.addNode(new Node("tag_2","id_2"));
			tagData.addNode(new Node("tag_3","id_3"));
			
			_rootNode.addNode(tagData);
			//用新数据刷新树
			browseTree.dataSource = _rootNode;
			_tagsListRendered = true;
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
	
	public function get type() : String {
		return _id;
	}
	
	
}