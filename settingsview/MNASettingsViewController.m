#include "MNASettingsViewController.h"

#define TABLE_BACKGROUND_COLOR "#EFEFF4"
#define TABLE_BACKGROUND_COLOR_DARKMODE "#000000"

@implementation MNASettingsViewController
- (id)init {
  self = [super init];
  if (self) {
    [self setTitle:@TWEAK_TITLE];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[MNAUtil localizedItem:@"APPLY"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];;
  
    self.navigationItem.titleView = [UIView new];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @TWEAK_TITLE;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationItem.titleView addSubview:self.titleLabel];

    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", @PREF_BUNDLE_PATH, @"icon@2x.png"]];
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconView.alpha = 0.0;
    [self.navigationItem.titleView addSubview:self.iconView];
    
    [NSLayoutConstraint activateConstraints:@[
      [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
      [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
      [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
      [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
      [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
      [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
      [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
      [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
    ]];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // set switches color
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  self.view.tintColor = [MNAUtil colorFromHex:[MNAUtil isDarkMode] ? @KTINT_COLOR_DARKMODE : @KTINT_COLOR];
  keyWindow.tintColor = [MNAUtil colorFromHex:[MNAUtil isDarkMode] ? @KTINT_COLOR_DARKMODE : @KTINT_COLOR];
  [UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = [MNAUtil colorFromHex:[MNAUtil isDarkMode] ? @KTINT_COLOR_DARKMODE : @KTINT_COLOR];
  // set navigation bar color
  self.navigationController.navigationBar.barTintColor = [MNAUtil colorFromHex:[MNAUtil isDarkMode] ? @KTINT_COLOR_DARKMODE : @KTINT_COLOR];
  self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
  [self.navigationController.navigationBar setShadowImage: [UIImage new]];
  self.navigationController.navigationController.navigationBar.translucent = NO;
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
  // set status bar text color
  // [UIApplication sharedApplication] 
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  keyWindow.tintColor = [MNAUtil isDarkMode] ? [UIColor whiteColor] : [UIColor blackColor]; // should be nil for default, but Messenger uses black/white
  self.navigationController.navigationBar.barTintColor = nil;
  self.navigationController.navigationBar.tintColor = nil;
  [self.navigationController.navigationBar setShadowImage:nil];
  [self.navigationController.navigationBar setTitleTextAttributes:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // init table view
  CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
  CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
  CGRect tableFrame;
  if (self.modalPresentationStyle == UIModalPresentationFullScreen) {
    tableFrame = CGRectMake(0, statusBarHeight + navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - statusBarHeight - navigationBarHeight);
  } else {
    tableFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight);
  }
  _tableView = [[UITableView alloc] initWithFrame:tableFrame];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.alwaysBounceVertical = NO;
  _tableView.backgroundColor = [MNAUtil colorFromHex:[MNAUtil isDarkMode] ? @TABLE_BACKGROUND_COLOR_DARKMODE : @TABLE_BACKGROUND_COLOR];
  [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [self.view addSubview:_tableView];
  
  // setup table image header
  self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  self.headerImageView.contentMode = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
  self.headerImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", @PREF_BUNDLE_PATH, @"Banner.jpg"]];
  self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

  [self.headerView addSubview:self.headerImageView];
  [NSLayoutConstraint activateConstraints:@[
    [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
    [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
    [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
    [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
  ]];

  _tableView.tableHeaderView = self.headerView;

  // setup table rows
  [self initTableData];
}

- (void)initTableData {
  _tableData = [@[] mutableCopy];

  MNACellModel *mainPreferencesCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@" " withSubtitle:[[MNAUtil localizedItem:@"MAIN_PREFERENCES"] uppercaseString]];
  MNACellModel *noAdsSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:[MNAUtil localizedItem:@"NO_ADS"]];
  noAdsSwitchCell.prefKey = @"noads";
  noAdsSwitchCell.defaultValue = @"true";
  MNACellModel *disableReadReceiptSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:[MNAUtil localizedItem:@"DISABLE_READ_RECEIPT"]];
  disableReadReceiptSwitchCell.prefKey = @"disablereadreceipt";
  disableReadReceiptSwitchCell.defaultValue = @"true";
  MNACellModel *disableTypingIndicatorSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:[MNAUtil localizedItem:@"DISABLE_TYPING_INDICATOR"]];
  disableTypingIndicatorSwitchCell.prefKey = @"disabletypingindicator";
  disableTypingIndicatorSwitchCell.defaultValue = @"true";
  MNACellModel *disableStorySeenReceiptSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:[MNAUtil localizedItem:@"DISABLE_STORY_SEEN_RECEIPT"]];
  disableStorySeenReceiptSwitchCell.prefKey = @"disablestoryseenreceipt";
  disableStorySeenReceiptSwitchCell.defaultValue = @"true";
  MNACellModel *canSaveFriendsStorySwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:[MNAUtil localizedItem:@"CAN_SAVE_FRIENDS_STORY"]];
  canSaveFriendsStorySwitchCell.prefKey = @"cansavefriendsstory";
  canSaveFriendsStorySwitchCell.defaultValue = @"true";
  MNACellModel *hideSearchBarSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:[MNAUtil localizedItem:@"HIDE_SEARCH_BAR"]];
  hideSearchBarSwitchCell.prefKey = @"hidesearchbar";
  hideSearchBarSwitchCell.defaultValue = @"false";
  if (@available(iOS 13, *)) {
    hideSearchBarSwitchCell.disabled = TRUE;
  }
  MNACellModel *hideStoriesRowSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:[MNAUtil localizedItem:@"HIDE_STORIES_ROW"]];
  hideStoriesRowSwitchCell.prefKey = @"hidestoriesrow";
  hideStoriesRowSwitchCell.defaultValue = @"false";
  MNACellModel *hidePeopleTabSwitchCell = [[MNACellModel alloc] initWithType:Switch withLabel:[MNAUtil localizedItem:@"HIDE_PEOPLE_TAB"]];
  hidePeopleTabSwitchCell.prefKey = @"hidepeopletab";
  hidePeopleTabSwitchCell.defaultValue = @"false";

  MNACellModel *otherPreferencesCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@" " withSubtitle:[[MNAUtil localizedItem:@"OTHER_PREFERENCES"] uppercaseString]];
  MNACellModel *resetSettingsButtonCell = [[MNACellModel alloc] initWithType:Button withLabel:[MNAUtil localizedItem:@"RESET_SETTINGS"]];
  resetSettingsButtonCell.buttonAction = @selector(resetSettings);

  MNACellModel *supportMeCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@" " withSubtitle:[[MNAUtil localizedItem:@"SUPPORT_ME"] uppercaseString]];
  MNACellModel *haoNguyenCell = [[MNACellModel alloc] initWithType:Link withLabel:@"Hao Nguyen 👨🏻‍💻" withSubtitle:@"@haoict"];
  haoNguyenCell.url = @"https://twitter.com/haoict";
  MNACellModel *donationCell = [[MNACellModel alloc] initWithType:Link withLabel:[MNAUtil localizedItem:@"DONATION"] withSubtitle:[MNAUtil localizedItem:@"BUY_ME_A_COFFEE"]];
  donationCell.url = @"https://paypal.me/haoict";
  MNACellModel *featureRequestCell = [[MNACellModel alloc] initWithType:Link withLabel:[MNAUtil localizedItem:@"FEATURE_REQUEST"] withSubtitle:[MNAUtil localizedItem:@"SEND_ME_AN_EMAIL_WITH_YOUR_REQUEST"]];
  featureRequestCell.url = @"mailto:hao.ict56@gmail.com?subject=Messenger%20No%20Ads%20Feature%20Request";
  MNACellModel *sourceCodeCell = [[MNACellModel alloc] initWithType:Link withLabel:[MNAUtil localizedItem:@"SOURCE_CODE"] withSubtitle:@"Github"];
  sourceCodeCell.url = @"https://github.com/haoict/messenger-no-ads";
  MNACellModel *foundABugCell = [[MNACellModel alloc] initWithType:Link withLabel:[MNAUtil localizedItem:@"FOUND_A_BUG"] withSubtitle:[MNAUtil localizedItem:@"LEAVE_A_BUG_REPORT_ON_GITHUB"]];
  foundABugCell.url = @"https://github.com/haoict/messenger-no-ads/issues/new";
  
  MNACellModel *emptyCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@" "];
  MNACellModel *footerCell = [[MNACellModel alloc] initWithType:StaticText withLabel:@"Messenger No Ads, made with 💖"];

  [_tableData addObject:mainPreferencesCell];
  [_tableData addObject:noAdsSwitchCell];
  [_tableData addObject:disableReadReceiptSwitchCell];
  [_tableData addObject:disableTypingIndicatorSwitchCell];
  [_tableData addObject:disableStorySeenReceiptSwitchCell];
  [_tableData addObject:canSaveFriendsStorySwitchCell];
  [_tableData addObject:hideSearchBarSwitchCell];
  [_tableData addObject:hideStoriesRowSwitchCell];
  [_tableData addObject:hidePeopleTabSwitchCell];

  [_tableData addObject:otherPreferencesCell];
  [_tableData addObject:resetSettingsButtonCell];

  [_tableData addObject:supportMeCell];
  [_tableData addObject:haoNguyenCell];
  [_tableData addObject:donationCell];
  [_tableData addObject:featureRequestCell];
  [_tableData addObject:sourceCodeCell];
  [_tableData addObject:foundABugCell];

  [_tableData addObject:emptyCell];
  [_tableData addObject:footerCell];
}

- (void)close {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  tableView.tableHeaderView = self.headerView;
  MNACellModel *cellData = [_tableData objectAtIndex:indexPath.row];

  NSString *cellIdentifier = [NSString stringWithFormat:@"MNATableViewCell-type%lu-title%@-subtitle%@", cellData.type, cellData.label, cellData.subtitle];
  MNATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if(cell == nil) {
    cell = [[MNATableViewCell alloc] initWithData:cellData reuseIdentifier:cellIdentifier viewController:self];
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  MNACellModel *cellData = [_tableData objectAtIndex:indexPath.row];
  if (cellData.type == Link) {
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:[NSURL URLWithString:cellData.url] options:@{} completionHandler:nil];
  }

  if (cellData.type == Button) {
    SEL selector = cellData.buttonAction;
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
  }

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  });
}

- (void)resetSettings {
  NSString *plistPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @PLIST_FILENAME];
  [@{} writeToFile:plistPath atomically:YES];
  [_tableView reloadData];
  notify_post(PREF_CHANGED_NOTIF);
  [MNAUtil showAlertMessage:nil title:@"Done" viewController:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat offsetY = scrollView.contentOffset.y;
  if (offsetY > 200) {
    [UIView animateWithDuration:0.2 animations:^{
      self.iconView.alpha = 1.0;
      self.titleLabel.alpha = 0.0;
    }];
  } else {
    [UIView animateWithDuration:0.2 animations:^{
      self.iconView.alpha = 0.0;
      self.titleLabel.alpha = 1.0;
    }];
  }
  if (offsetY > 0) offsetY = 0;
  self.headerImageView.frame = CGRectMake(0, offsetY, self.headerView.frame.size.width, 200 - offsetY);
}

@end