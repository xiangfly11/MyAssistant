//
//  EditNotesViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 9/7/15.
//  Copyright (c) 2015 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NotesEntry.h"
#import "NewNotesEntity.h"
@interface EditNotesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong,nonatomic) NewNotesEntity *entry;


@end
