
@class MPUContentItemIdentifierCollection;





@interface MusicLibraryActionDeleteOperation : NSOperation
{
	MPUContentItemIdentifierCollection* _contentItemIdentifierCollection;
}

@property (copy,readonly) MPUContentItemIdentifierCollection * contentItemIdentifierCollection;

- (id)initWithContentItemIdentifierCollection:(id)arg1;
- (void)main; // delete item
- (MPUContentItemIdentifierCollection *)contentItemIdentifierCollection;

@end




