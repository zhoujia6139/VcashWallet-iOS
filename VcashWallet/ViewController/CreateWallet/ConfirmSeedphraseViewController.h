//
//  ConfirmSeedphraseViewController.h
//  VcashWallet
//
//  Created by 盛杰厚 on 2019/5/22.
//  Copyright © 2019 blockin. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfirmSeedphraseViewController : BaseViewController

@property (nonatomic, assign) BOOL recoveryPhrase;

@property (strong, nonatomic)NSArray* mnemonicWordsArr;



@end

typedef void(^ChosePhraseCallBack)(NSInteger index);

@interface ChosePhraseItemView : UIView

@property (nonatomic, strong) NSString *title;

@property (nonatomic, copy) ChosePhraseCallBack chosePhraseCallBack;

+ (UIView *)creatPhraseViewWithParentView:(UIView *)view phraseArr:(NSArray *)phraseArr choseCallBack:(ChosePhraseCallBack)choseCallBack;

@end

NS_ASSUME_NONNULL_END
