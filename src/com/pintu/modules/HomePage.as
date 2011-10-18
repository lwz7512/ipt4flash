package com.pintu.modules
{
	import com.pintu.api.IPintu;
	import com.pintu.widgets.AndiBlock;
	import com.pintu.widgets.UserDetailsBlock;
	import com.pintu.widgets.WeiboFriendsBlock;
	
	import flash.display.Sprite;
	
	public class HomePage extends Sprite
	{
		private var model:IPintu;
		
		public function HomePage(model:IPintu)
		{
			super();
			this.model = model;
			
			buildMainToolBar();
			buildLeftCategoryTree();
			buildMainDisplayArea();
			buildSlideToolBar();
			buildRightColumns();
		}
		
		private function buildMainToolBar():void{
			
		}
		
		private function buildLeftCategoryTree():void{
			
		}
		
		private function buildMainDisplayArea():void{
			
		}
		
		private function buildSlideToolBar():void{
			
		}
		
		private function buildRightColumns():void{
			var userDetails:UserDetailsBlock = new UserDetailsBlock();
			this.addChild(userDetails);
			var andiAssets:AndiBlock = new AndiBlock();
			this.addChild(andiAssets);
			var weiboFriends:WeiboFriendsBlock = new WeiboFriendsBlock();
			this.addChild(weiboFriends);
			
		}
		
		
		
		
		
	} //end of class
}