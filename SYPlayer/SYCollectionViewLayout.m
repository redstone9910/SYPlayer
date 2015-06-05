//
//  SYCollectionViewLayout.m
//  SYPlayer
//
//  Created by YinYanhui on 15-5-10.
//  Copyright (c) 2015年 YinYanhui. All rights reserved.
//

#import "SYCollectionViewLayout.h"
@interface SYCollectionViewLayout()

@end
@implementation SYCollectionViewLayout
-(CGSize)collectionViewContentSize{
    return self.collectionView.bounds.size;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *attributes = [NSMutableArray array];
    
    NSArray *array = [self indexPathsOfItemsInRect:rect];
    for (NSIndexPath *path in array) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:path];
        [attributes addObject:attr];
    }
    
    return attributes;
}

- (NSArray *)indexPathsOfItemsInRect:(CGRect) rect
{
    // For the purposes of this CollectionView, all items are always visible.
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSUInteger sections = [self.collectionView numberOfSections];
    
    for (NSUInteger section = 0; section < sections; section++) {
        for (NSInteger row = 0; row < [self.collectionView numberOfItemsInSection:section]; row++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:row inSection:section]];
        }
    }
    
    return indexPaths;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    float retio = self.collectionView.bounds.size.width / self.collectionView.bounds.size.height;
    
    float cellW;
    float cellH;
    float cellX;
    float cellY;
    float cellCX;
    float cellCY;
    if (retio > (3.0 / 1.2)) {
        cellW = self.collectionView.bounds.size.width / 4;
        cellH = self.collectionView.bounds.size.height;
        cellCX = (indexPath.row % 4 + 0.5) * cellW;
        cellCY = (indexPath.row / 4 + 0.5) * cellH;
    }else{
        cellW = self.collectionView.bounds.size.width / 2;
        cellH = self.collectionView.bounds.size.height / 2;
        cellCX = (indexPath.row % 2 + 0.5) * cellW;
        cellCY = (indexPath.row / 2 + 0.5) * cellH;
    }
    
    cellW *= 0.7;
    cellH *= 0.7;
    cellX = cellCX - cellW / 2;
    cellY = cellCY - cellH / 2;
    layoutAttributes.frame = CGRectMake(cellX, cellY, cellW, cellH);
    return layoutAttributes;
}
@end
