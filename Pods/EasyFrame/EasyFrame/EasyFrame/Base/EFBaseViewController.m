//
//  EFBaseViewController.m
//  EasyFrame
//
//  Created by  rjt on 15/6/12.
//  Copyright (c) 2015年 交易支点. All rights reserved.
//

#import "EFBaseViewController.h"
#import "EFBll.h"
#import "UIBarButtonItem+YL.h"

@interface EFBaseViewController ()

@end

@implementation EFBaseViewController

+(instancetype)controllerWithModel:(EFBaseViewModel *)viewModel nibName:(NSString *)nibName bundle:(NSBundle *)bundle{
    EFBaseViewController *instance = [[self alloc] initWithNibName:nibName bundle:bundle];
    if ([viewModel isKindOfClass:[instance typeOfModel]]) {
        instance.viewModel = viewModel;
    }
    return instance;
}

+(instancetype)controllerWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle{
    EFBaseViewController *instance = [[self alloc] initWithNibName:nibName bundle:bundle];
    return instance;
}

+(instancetype)controller{
    NSString* nibName=NSStringFromClass([self class]);
    EFBaseViewController* controller=[[self alloc] initWithNibName:nibName bundle:nil];
    return controller;
}


-(Class)typeOfModel{
    return [EFBaseViewModel class];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化默认参数
    _navBarHidden = NO;
    _statusBarStyle = UIStatusBarStyleLightContent;
    
//    UINavigationBar * bar = self.navigationController.navigationBar;
//    bar.barTintColor = kColorNavBar;
//    bar.translucent =  NO;//不透明
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kColorNavTitle,NSForegroundColorAttributeName,[UIFont systemFontOfSize:18.f],NSFontAttributeName,nil]];
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
    blls = [NSHashTable weakObjectsHashTable];
    self.edgesForExtendedLayout=UIRectEdgeNone;//使Tablebar能撑满整个屏幕;
    [self initBll];
    [self bindViewModel];
}

-(void)bindViewModel{

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.navBarHidden];
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
    
    NSEnumerator *enumerator = [blls objectEnumerator];
    id obj = nil;
    while (obj = [enumerator nextObject]) {
        if ([obj isKindOfClass:[EFBll class]]) {
            EFBll *tmpbll = (EFBll*)obj;
            [tmpbll controllerWillAppear];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSEnumerator *enumerator = [blls objectEnumerator];
    id obj = nil;
    while (obj = [enumerator nextObject]) {
        if ([obj isKindOfClass:[EFBll class]]) {
            EFBll *tmpbll = (EFBll*)obj;
            [tmpbll controllerDidAppear];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    NSEnumerator *enumerator = [blls objectEnumerator];
    id obj = nil;
    while (obj = [enumerator nextObject]) {
        if ([obj isKindOfClass:[EFBll class]]) {
            EFBll *tmpbll = (EFBll*)obj;
            [tmpbll controllerDidDisappear];
        }
    }
}

-(void)initBll{

}

-(void)registerBll:(EFBll *)bll{
    if (bll) {
        [blls addObject:bll];
    }
}


-(void)setRightNavBarWithTitle:(NSString *)title titleColor:(UIColor *)color action:(SEL)action{
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]
                            initWithTitle:title
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:action];
    if (color) {
        btn.tintColor = color;
    }
    self.navigationItem.rightBarButtonItem= btn;
}

-(void)setRightNavBarWithImage:(NSString*)image heighLight:(NSString*)heighlight action:(SEL)action{

    self.navigationItem.rightBarButtonItem= [UIBarButtonItem buttonItemWithIcon:image highlightedIcon:heighlight target:self action:action];
}


-(void)addSwither:(UIControl*)sw forBll:(EFBll*)bll{
    if (switcher == nil) {
        switcher = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    [sw addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchDown];
    [bll hide];
    [switcher setObject:bll forKey:sw];
}

-(void)switchClicked:(id)obj{
    NSEnumerator* enu = [switcher keyEnumerator];
    //找到前一次被选中的按钮和bll
    EFBll* oldBll = nil;
    UIControl* oldSw = nil;
    for (UIControl* sw in enu) {
        EFBll *bll = [switcher objectForKey:sw];
        if (!bll.isHidden) {
            oldBll = bll;
            oldSw = sw;
            break;
        }
    }
    [oldBll hide];
    EFBll *bll = [switcher objectForKey:obj];
    [bll show];
    [self swither:obj andBll:bll fromSwitcher:oldSw andBll:oldBll];
}

-(void)swither:(UIControl *)sw andBll:(EFBll *)bll fromSwitcher:(UIControl *)oldSw andBll:(EFBll *)oldbll{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissViewControllerAnimated:(BOOL)flag userObj:(id)userObj completion:(void (^)(void))completion {
    if([self.delegate respondsToSelector:@selector(viewController:dismissedWithObject:)]){
        [self.delegate viewController:self dismissedWithObject:userObj];
    }
    [super dismissViewControllerAnimated:flag completion:completion];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    show_dealloc_info(self);
}
@end
