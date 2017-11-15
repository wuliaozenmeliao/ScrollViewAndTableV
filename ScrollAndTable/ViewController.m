//
//  ViewController.m
//  ScrollAndTable
//
//  Created by XinGou on 2017/11/15.
//  Copyright © 2017年 XinGou. All rights reserved.
//

#import "ViewController.h"
#import "KJTableViewController.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property(nonatomic,strong)UIView *headerVC;
@property(nonatomic,strong)UIView *selectVC;
@property(nonatomic,assign)CGPoint lastOffset;
@property (strong, nonatomic) KJTableViewController *currentViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self setUI];
}
-(void)setUI
{
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.contentScrollView.delegate = self;
    self.contentScrollView.backgroundColor = [UIColor yellowColor];
    self.contentScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:self.contentScrollView];
    [self addchildsVC];
    _headerVC = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    _headerVC.backgroundColor = [UIColor redColor];
    [self.view addSubview:_headerVC];
    
    _selectVC = [[UIView alloc] initWithFrame:CGRectMake(0, 200, kScreenWidth, 50)];
    _selectVC.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_selectVC];
}
-(void)addchildsVC
{
    for (int i = 0; i<3; i++) {
        KJTableViewController *table = [[KJTableViewController alloc] init];
        CGFloat x = kScreenWidth * i;
        table.view.frame = CGRectMake(x, 0, kScreenWidth, kScreenHeight);
        [self addChildViewController:table];
        [self.contentScrollView addSubview:table.view];
        [table didMoveToParentViewController:self];
        [table.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    self.currentViewController = self.childViewControllers[0];
    self.contentScrollView.contentSize = CGSizeMake(kScreenWidth * self.childViewControllers.count, 0);
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UITableView *tableView= (UITableView*)object;
        CGPoint offset = [change[NSKeyValueChangeNewKey]CGPointValue];
        CGFloat y = offset.y;
        if (y<0) {
            _headerVC.frame = CGRectMake(0, 0, kScreenWidth, 200);
            _selectVC.frame = CGRectMake(0, 200, kScreenWidth, 50);
        }else if (y<200){
            _headerVC.frame = CGRectMake(0, -y, kScreenWidth, 200);
            _selectVC.frame = CGRectMake(0, 200-y, kScreenWidth, 50);
        }else{
            _headerVC.frame = CGRectMake(0, -200, kScreenWidth, 200);
            _selectVC.frame = CGRectMake(0, 0, kScreenWidth, 50);
        }
        self.lastOffset = tableView.contentOffset;
    }
}
-(void)dealloc
{
    for (NSInteger i = 0; i < self.childViewControllers.count; i++) {
        KJTableViewController *vc = self.childViewControllers[i];
        [vc.tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat tableViewOffsetY = self.lastOffset.y;
    
    if (tableViewOffsetY<0) {
        for (KJTableViewController *vc in self.childViewControllers) {
            if (self.currentViewController != vc) {
                vc.tableView.contentOffset = CGPointMake(0, 0);
            }
        }
    }else if (tableViewOffsetY<200){
        for (KJTableViewController *vc in self.childViewControllers) {
            if (self.currentViewController != vc) {
                vc.tableView.contentOffset = self.lastOffset;
            }
        }
    }else{
        for (KJTableViewController *vc in self.childViewControllers) {
            if (self.currentViewController != vc) {
                vc.tableView.contentOffset = CGPointMake(0, 200);
            }
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/kScreenWidth;
    KJTableViewController *vc = self.childViewControllers[index];
    self.currentViewController = vc;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
