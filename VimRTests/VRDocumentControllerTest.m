/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import "VRBaseTestCase.h"
#import "VRMainWindowController.h"
#import "VRWorkspace.h"
#import "VRWorkspaceController.h"


static const int PID = 1;
static const int CONTROLLER_ID = 2;

@interface VRDocumentControllerTest : VRBaseTestCase

@end

@implementation VRDocumentControllerTest {
    VRWorkspaceController *documentController;

    VRWorkspace *doc;
    VRMainWindowController *mainWindowController;
    MMVimManager *vimManager;
    MMVimController *vimController;
    MMVimView *vimView;
}

- (void)setUp {
    [super setUp];

    doc = mock([VRWorkspace class]);
    mainWindowController = mock([VRMainWindowController class]);
    vimManager = mock([MMVimManager class]);
    vimController = mock([MMVimController class]);
    vimView = mock([MMVimView class]);

    documentController = [[VRWorkspaceController alloc] init];
    documentController.vimManager = vimManager;

    [given([doc mainWindowController]) willReturn:mainWindowController];
    [given([doc fileURL]) willReturn:[NSURL URLWithString:@"file:///tmp"]];
    [given([vimManager pidOfNewVimControllerWithArgs:nil]) willReturnInt:PID];
    [given([vimController vimView]) willReturn:vimView];
    [given([vimController pid]) willReturnInt:PID];
    [given([vimController vimControllerId]) willReturnUnsignedInt:CONTROLLER_ID];

}

- (void)testRequestVimControllerForDocument {
    [documentController requestVimControllerForDocument:doc];

    [verify(vimManager) pidOfNewVimControllerWithArgs:@{
            qVimArgFileNamesToOpen : @[@"/tmp"]
    }];
}

- (void)testManagerVimControllerCreated {
    [documentController requestVimControllerForDocument:doc];
    [documentController manager:vimManager vimControllerCreated:vimController];

    [verify(vimController) setDelegate:doc.mainWindowController];
    [verify(mainWindowController) setVimController:vimController];
    [verify(mainWindowController) setVimView:vimView];
}

- (void)testManagerVimControllerRemovedWithControllerIdPid {
    [documentController requestVimControllerForDocument:doc];
    [documentController manager:vimManager vimControllerCreated:vimController];

    [documentController manager:vimManager vimControllerRemovedWithControllerId:CONTROLLER_ID pid:PID];

    [verify(doc) close];
}

- (void)testMenuItemTemplateForManager {
    assertThat([documentController menuItemTemplateForManager:vimManager], notNilValue());
}

@end
