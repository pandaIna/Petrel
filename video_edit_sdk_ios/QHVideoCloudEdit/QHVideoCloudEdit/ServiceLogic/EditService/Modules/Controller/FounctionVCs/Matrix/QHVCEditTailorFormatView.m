//
//  QHVCEditTailorFormatView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTailorFormatView.h"
#import "QHVCEditTailorFillCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"

static NSString * const fillCellIdentifier = @"QHVCEditTailorFillCell";
static NSString * const colorCellIdentifier = @"QHVCEditFrameCell";

@interface  QHVCEditTailorFormatView()
{
    __weak IBOutlet UIButton *_fillBtn;
    __weak IBOutlet UIButton *_colorBtn;
    __weak IBOutlet UICollectionView *_collectionView;
    NSInteger _selectedTabIndex;
    NSInteger _fillIndex;
    NSInteger _colorIndex;
}

@property (nonatomic, strong) NSArray *fillsArray;
@property (nonatomic, strong) NSArray *colorsArray;

@end

@implementation QHVCEditTailorFormatView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_collectionView registerNib:[UINib nibWithNibName:fillCellIdentifier bundle:nil] forCellWithReuseIdentifier:fillCellIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:colorCellIdentifier bundle:nil] forCellWithReuseIdentifier:colorCellIdentifier];
    
    _selectedTabIndex = 0;
    _fillIndex = [[QHVCEditMediaEditorConfig sharedInstance] mainTrackFillModeIndex];
    _colorIndex = [[QHVCEditMediaEditorConfig sharedInstance] mainTrackBgColorIndex];
    
    _fillsArray = @[@"黑边填充",@"裁剪填充",@"变形填充"];
    _colorsArray = @[@[@"edit_color_blur",@"blur"],@[@"edit_color_black",@"000000"],@[@"edit_color_blue",@"125FDF"],
                     @[@"edit_color_gray",@"888888"],@[@"edit_color_green",@"25B727"],@[@"edit_color_pink",@"FE8AB1"],
                     @[@"edit_color_red",@"F54343"],@[@"edit_color_white",@"FFFFFF"],@[@"edit_color_yellow",@"FFDB4F"]];
    [_collectionView reloadData];
}

- (void)updateView:(NSArray *)fillArray colors:(NSArray *)colorsArray
{
    self.fillsArray = fillArray;
    self.colorsArray = colorsArray;
    [_collectionView reloadData];
}

- (IBAction)formatAction:(UIButton *)sender
{
    if (sender.tag == _selectedTabIndex)
    {
        return;
    }
    _selectedTabIndex = sender.tag;
    if (sender.tag == 0) {
        [_fillBtn setImage:[UIImage imageNamed:@"edit_format_fill_h"] forState:UIControlStateNormal];
        [_fillBtn setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
        
        [_colorBtn setImage:[UIImage imageNamed:@"edit_format_color"] forState:UIControlStateNormal];
        [_colorBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
    }
    else
    {
        [_fillBtn setImage:[UIImage imageNamed:@"edit_format_fill"] forState:UIControlStateNormal];
        [_fillBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
        
        [_colorBtn setImage:[UIImage imageNamed:@"edit_format_color_h"] forState:UIControlStateNormal];
        [_colorBtn setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
    }
    [_collectionView reloadData];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_selectedTabIndex == 0)
    {
        return _fillsArray.count;
    }
    else if (_selectedTabIndex == 1)
    {
        return _colorsArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedTabIndex == 0)
    {
        QHVCEditTailorFillCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:fillCellIdentifier forIndexPath:indexPath];
        [cell updateCell:_fillsArray[indexPath.row] isSelected:(indexPath.row == _fillIndex)];
        return cell;
    }
    else if(_selectedTabIndex == 1)
    {
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:colorCellIdentifier forIndexPath:indexPath];
        [cell updateCell:[UIImage imageNamed:_colorsArray[indexPath.row][0]] highlightViewType:indexPath.row == _colorIndex?QHVCEditFrameHighlightViewTypeSquare:QHVCEditFrameHighlightViewTypeNone];
        [cell setImageFillMode:UIViewContentModeCenter];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedTabIndex == 0)
    {
        return CGSizeMake(kScreenWidth, 35);
    }
    return CGSizeMake(52, 52);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedTabIndex == 0)
    {
        if (_fillIndex != indexPath.row)
        {
            _fillIndex = indexPath.row;
            [_collectionView reloadData];
            [self onFillModeChanged:indexPath.row];
        }
    }
    else if (_selectedTabIndex == 1)
    {
        if (_colorIndex != indexPath.row)
        {
            _colorIndex = indexPath.row;
            [_collectionView reloadData];
            [self onColorChanged:indexPath.row];
        }
    }
}

- (IBAction)onConfirmAction:(id)sender
{
    [self removeFromSuperview];
}

- (void)onFillModeChanged:(NSInteger)index
{
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackFillModeIndex:index];
    QHVCEditSequenceTrack* mainTrack = [[QHVCEditMediaEditor sharedInstance] getMainVideoTrack];
    [mainTrack setFillMode:(QHVCEditFillMode)index];
    SAFE_BLOCK(self.refreshPlayerBlock);
}

- (void)onColorChanged:(NSInteger)index
{
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackBgColorIndex:index];
    QHVCEditSequenceTrack* mainTrack = [[QHVCEditMediaEditor sharedInstance] getMainVideoTrack];
    QHVCEditBgParams* bgParam = [[QHVCEditBgParams alloc] init];
    if (index == 0)
    {
        [bgParam setMode:QHVCEditBgModeBlur];
    }
    else
    {
        NSString* rgb = _colorsArray[index][1];
        [bgParam setMode:QHVCEditBgModeColor];
        [bgParam setBgInfo:[@"FF" stringByAppendingString:rgb]];
    }
    [mainTrack setBgParams:bgParam];
    SAFE_BLOCK(self.refreshPlayerBlock);
}

@end
