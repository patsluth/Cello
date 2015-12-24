
#import "MusicEntityProviding.h"

@class MusicMediaQueryDataSource, MPMediaQuery;

@interface MusicMediaQueryDataSource : NSObject

- (id)entities;

@end





@interface MusicMediaEntityProvider : NSObject <MusicEntityProviding, NSCoding>
{
}

@property (assign, nonatomic) long long maximumItemCount;
@property (nonatomic, readonly) MusicMediaQueryDataSource *mediaQueryDataSource;
@property (nonatomic, retain) MPMediaQuery *mediaQuery;

- (id)initWithMediaQueryDataSource:(id)arg1;
- (id)initWithMediaQuery:(id)arg1;

- (BOOL)hasEntities;
- (BOOL)hasEntitiesNotInLibrary;

- (unsigned long long)numberOfSections;
- (void)configureEntityValueContextOutputForAnyIndexPath:(id)arg1;
- (id)indexBarEntryAtIndex:(unsigned long long)arg1;
- (void)configureEntityValueContextOutput:(id)arg1 forIndexPath:(id)arg2;
- (void)configureSectionEntityValueContextOutput:(id)arg1 forIndex:(unsigned long long)arg2;
- (id)indexPathForEntityValueContext:(id)arg1;
- (void)_handleMediaQueryDataSourceDidInvalidate;
- (void)_configureEntityValueContextOutput:(id)arg1 forGlobalIndex:(unsigned long long)arg2;
- (void)_dataSourceWasInvalidated:(id)arg1;
- (id)_localizedSectionIndexTitles;
- (id)_requiredVisibilityPrioritySectionIndexTitles;
- (void)_loadSectionIndexTitleDataIfNeeded;
- (id)entityValueProviderAtIndexPath:(id)arg1;
- (unsigned long long)numberOfEntitiesInSection:(unsigned long long)arg1;
- (unsigned long long)numberOfIndexBarEntries;
- (unsigned long long)sectionForSectionIndexBarEntryAtIndex:(unsigned long long)arg1;

@end




