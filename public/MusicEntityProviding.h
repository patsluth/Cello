
@protocol MusicEntityProviding // <SKUIEntityProviding>

@optional

- (BOOL)hasEntitiesNotInLibrary;
- (void)setEditing:(BOOL)arg1 returningInsertedSectionIndexSet:(id *)arg2 deletedSectionIndexSet:(id *)arg3;

@required

- (BOOL)hasEntities;
- (unsigned long long)numberOfSections;
- (void)configureEntityValueContextOutputForAnyIndexPath:(id)arg1;
- (id)indexBarEntryAtIndex:(unsigned long long)arg1;
- (void)configureEntityValueContextOutput:(id)arg1 forIndexPath:(id)arg2;
- (void)configureSectionEntityValueContextOutput:(id)arg1 forIndex:(unsigned long long)arg2;
- (id)indexPathForEntityValueContext:(id)arg1;
- (id)entityValueProviderAtIndexPath:(id)arg1;
- (unsigned long long)numberOfEntitiesInSection:(unsigned long long)arg1;
- (unsigned long long)numberOfIndexBarEntries;
- (unsigned long long)sectionForSectionIndexBarEntryAtIndex:(unsigned long long)arg1;

@end




