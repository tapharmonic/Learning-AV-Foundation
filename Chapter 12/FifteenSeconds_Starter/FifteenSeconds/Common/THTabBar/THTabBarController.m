//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THTabBarController.h"
#import "THTabBarControllerView.h"
#import "THTabBarButton.h"
#import "THTabBarItem.h"

#define STATUS_BAR_HEIGHT 20.0f

@interface THTabBarController ()
@property(nonatomic) NSInteger lastSelectedIndex;
@end

@implementation THTabBarController

- (void)setup {
    _lastSelectedIndex = 0;
}

- (id)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
	[self performSegueWithIdentifier:@"THSetVideoPickerViewController" sender:self];
	[self performSegueWithIdentifier:@"THSetAudioPickerViewController" sender:self];
}

- (void)setTabBarAnchor:(THTabBarAnchor)tabBarAnchor {
    _tabBarAnchor = tabBarAnchor;
    [(THTabBarControllerView *) self.view setTabBarAnchor:tabBarAnchor];
    [self.view setNeedsLayout];
}

- (void)loadView {
    self.view = [[THTabBarControllerView alloc] initWithFrame:CGRectZero];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    // Create THTabBarButton instances
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:self.tabBarItems.count];

    for (NSUInteger i = 0; i < self.tabBarItems.count; i++) {
        THTabBarItem *item = [self.tabBarItems objectAtIndex:i];
        THTabBarButton *button = [[THTabBarButton alloc] initWithImageName:item.imageName];
        item.button = button;

        [buttons addObject:button];
    }

    THTabBarView *tabBarView = [(THTabBarControllerView *)self.view tabBarView];
    tabBarView.tabBarButtons = buttons;
    tabBarView.delegate = self;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [self setSelectedIndex:self.lastSelectedIndex];
}

- (void)setTabBarItems:(NSArray *)tabBarItems {
    if (_tabBarItems != tabBarItems) {
        // Remove old controllers from view controller hierarchy
        for (THTabBarItem *item in _tabBarItems) {
            [item.controller willMoveToParentViewController:nil];
            [item.controller removeFromParentViewController];
        }

        // Add the new controllers into the view controller hierarchy
        _tabBarItems = [tabBarItems copy];
        for (THTabBarItem *item in tabBarItems) {
            [self addChildViewController:item.controller];
            [item.controller didMoveToParentViewController:self];
        }
    }
}

- (void)setSelectedViewController:(UIViewController *)newViewController {
    if (_selectedViewController == newViewController) {
        return;
    }

    NSUInteger fromIndex = self.selectedIndex;

    UIViewController *oldViewController = _selectedViewController;
    _selectedViewController = newViewController;

    NSUInteger toIndex = self.selectedIndex;

    if (!oldViewController) {
        [(id)self.view setContentView:_selectedViewController.view animated:NO options:0];
    } else {
        THTabBarAnimationOption direction = fromIndex < toIndex ? THTabBarAnimationOptionRightToLeft : THTabBarAnimationOptionLeftToRight;
        [(id)self.view setContentView:_selectedViewController.view animated:self.animateTransitions options:direction];
    }

    THTabBarItem *item;

    for (NSUInteger i = 0; i < self.tabBarItems.count; ++i) {
        item = [self.tabBarItems objectAtIndex:i];
        [item.button setSelected:(item.controller == _selectedViewController)];
        if (item.button.selected) {
            self.lastSelectedIndex = i;
        }
        [item.button setNeedsDisplay];
    }
    //Post notification of tab change
    [[NSNotificationCenter defaultCenter] postNotificationName:THTabBarControllerTabChangedNotification object:nil];
}

- (void)setSelectedIndex:(NSUInteger)index {
    NSAssert1(index <= [self.tabBarItems count], @"%lu is an invalid index.", (unsigned long)index);

    UIViewController *viewController = [[self.tabBarItems objectAtIndex:index] controller];
    [self setSelectedViewController:viewController];
}

- (NSUInteger)selectedIndex {
    for (NSUInteger i = 0; i < self.tabBarItems.count; ++i) {
        if ([[self.tabBarItems objectAtIndex:i] controller] == self.selectedViewController) {
            return i;
        }
    }
    return 0;
}

- (BOOL)tabBar:(THTabBarView *)tabBar canSelectTabAtIndex:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        return [self.delegate tabBarController:self shouldSelectViewController:[[self.tabBarItems objectAtIndex:index] controller]];
    }
    return YES;
}

- (void)tabBar:(THTabBarView *)tabBar didSelectTabAtIndex:(NSUInteger)index {
    UIViewController *viewController = [[self.tabBarItems objectAtIndex:index] controller];
    // Make sure secondary tap pops to root just like UITabBarController
    if (self.selectedViewController == viewController && [self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *) self.selectedViewController popToRootViewControllerAnimated:YES];
    } else {
        self.selectedViewController = viewController;
    }
    // Notify delegate if it is interested
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [self.delegate tabBarController:self didSelectViewController:self.selectedViewController];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (self.selectedViewController) {
        return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    return YES;
}

@end
