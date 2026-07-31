#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "cloud" asset catalog image resource.
static NSString * const ACImageNameCloud AC_SWIFT_PRIVATE = @"cloud";

/// The "drop" asset catalog image resource.
static NSString * const ACImageNameDrop AC_SWIFT_PRIVATE = @"drop";

/// The "moon" asset catalog image resource.
static NSString * const ACImageNameMoon AC_SWIFT_PRIVATE = @"moon";

/// The "spoon" asset catalog image resource.
static NSString * const ACImageNameSpoon AC_SWIFT_PRIVATE = @"spoon";

/// The "umbrella" asset catalog image resource.
static NSString * const ACImageNameUmbrella AC_SWIFT_PRIVATE = @"umbrella";

#undef AC_SWIFT_PRIVATE
