/// Routes for the sharing namespace
public class SharingRoutes {
    public let client : BabelClient
    init(client: BabelClient) {
        self.client = client
    }
    /**
        Returns a list of LinkMetadata objects for this user, including collection links. If no path is given or the
        path is empty, returns a list of all shared links for the current user, including collection links. If a
        non-empty path is given, returns a list of all shared links that allow access to the given path.  Collection
        links are never returned in this case. Note that the url field in the response is never the shortened URL.

        - parameter path: See getSharedLinks description.

         - returns: Through the response callback, the caller will receive a `Sharing.GetSharedLinksResult` object on
        success or a `Sharing.GetSharedLinksError` object on failure.
    */
    public func getSharedLinks(path: String? = nil) -> BabelRpcRequest<Sharing.GetSharedLinksResultSerializer, Sharing.GetSharedLinksErrorSerializer> {
        let request = Sharing.GetSharedLinksArg(path: path)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/get_shared_links", params: Sharing.GetSharedLinksArgSerializer().serialize(request), responseSerializer: Sharing.GetSharedLinksResultSerializer(), errorSerializer: Sharing.GetSharedLinksErrorSerializer())
    }
    /**
        Create a shared link. If a shared link already exists for the given path, that link is returned. Note that in
        the returned PathLinkMetadata, the url in PathLinkMetadata field is the shortened URL if shortUrl in
        CreateSharedLinkArg argument is set to true. Previously, it was technically possible to break a shared link by
        moving or renaming the corresponding file or folder. In the future, this will no longer be the case, so your app
        shouldn't rely on this behavior. Instead, if your app needs to revoke a shared link, use revokeSharedLink.

        - parameter path: The path to share.
        - parameter shortUrl: Whether to return a shortened URL.
        - parameter pendingUpload: If it's okay to share a path that does not yet exist, set this to either file in
        PendingUploadMode or folder in PendingUploadMode to indicate whether to assume it's a file or folder.

         - returns: Through the response callback, the caller will receive a `Sharing.PathLinkMetadata` object on
        success or a `Sharing.CreateSharedLinkError` object on failure.
    */
    public func createSharedLink(path path: String, shortUrl: Bool = false, pendingUpload: Sharing.PendingUploadMode? = nil) -> BabelRpcRequest<Sharing.PathLinkMetadataSerializer, Sharing.CreateSharedLinkErrorSerializer> {
        let request = Sharing.CreateSharedLinkArg(path: path, shortUrl: shortUrl, pendingUpload: pendingUpload)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/create_shared_link", params: Sharing.CreateSharedLinkArgSerializer().serialize(request), responseSerializer: Sharing.PathLinkMetadataSerializer(), errorSerializer: Sharing.CreateSharedLinkErrorSerializer())
    }
    /**
        Revoke a shared link. This API is only supported for full dropbox apps.

        - parameter url: URL of the shared link.

         - returns: Through the response callback, the caller will receive a `Void` object on success or a
        `Sharing.RevokeSharedLinkError` object on failure.
    */
    public func revokeSharedLink(url url: String) -> BabelRpcRequest<VoidSerializer, Sharing.RevokeSharedLinkErrorSerializer> {
        let request = Sharing.RevokeSharedLinkArg(url: url)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/revoke_shared_link", params: Sharing.RevokeSharedLinkArgSerializer().serialize(request), responseSerializer: Serialization._VoidSerializer, errorSerializer: Sharing.RevokeSharedLinkErrorSerializer())
    }
    /**
        Return the list of all shared folders the current user has access to. Warning: This endpoint is in beta and is
        subject to minor but possibly backwards-incompatible changes.


         - returns: Through the response callback, the caller will receive a `Sharing.ListFoldersResult` object on
        success or a `Void` object on failure.
    */
    public func listFolders() -> BabelRpcRequest<Sharing.ListFoldersResultSerializer, VoidSerializer> {
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/list_folders", params: Serialization._VoidSerializer.serialize(), responseSerializer: Sharing.ListFoldersResultSerializer(), errorSerializer: Serialization._VoidSerializer)
    }
    /**
        Once a cursor has been retrieved from listFolders, use this to paginate through all shared folders. Warning:
        This endpoint is in beta and is subject to minor but possibly backwards-incompatible changes.

        - parameter cursor: The cursor returned by your last call to listFolders or listFoldersContinue.

         - returns: Through the response callback, the caller will receive a `Sharing.ListFoldersResult` object on
        success or a `Sharing.ListFoldersContinueError` object on failure.
    */
    public func listFoldersContinue(cursor cursor: String) -> BabelRpcRequest<Sharing.ListFoldersResultSerializer, Sharing.ListFoldersContinueErrorSerializer> {
        let request = Sharing.ListFoldersContinueArg(cursor: cursor)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/list_folders/continue", params: Sharing.ListFoldersContinueArgSerializer().serialize(request), responseSerializer: Sharing.ListFoldersResultSerializer(), errorSerializer: Sharing.ListFoldersContinueErrorSerializer())
    }
    /**
        Returns shared folder metadata by its folder ID. Warning: This endpoint is in beta and is subject to minor but
        possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.

         - returns: Through the response callback, the caller will receive a `Sharing.SharedFolderMetadata` object on
        success or a `Sharing.SharedFolderAccessError` object on failure.
    */
    public func getFolderMetadata(sharedFolderId sharedFolderId: String) -> BabelRpcRequest<Sharing.SharedFolderMetadataSerializer, Sharing.SharedFolderAccessErrorSerializer> {
        let request = Sharing.GetMetadataArgs(sharedFolderId: sharedFolderId)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/get_folder_metadata", params: Sharing.GetMetadataArgsSerializer().serialize(request), responseSerializer: Sharing.SharedFolderMetadataSerializer(), errorSerializer: Sharing.SharedFolderAccessErrorSerializer())
    }
    /**
        Returns shared folder membership by its folder ID. Warning: This endpoint is in beta and is subject to minor but
        possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.

         - returns: Through the response callback, the caller will receive a `Sharing.SharedFolderMembers` object on
        success or a `Sharing.SharedFolderAccessError` object on failure.
    */
    public func listFolderMembers(sharedFolderId sharedFolderId: String) -> BabelRpcRequest<Sharing.SharedFolderMembersSerializer, Sharing.SharedFolderAccessErrorSerializer> {
        let request = Sharing.ListFolderMembersArgs(sharedFolderId: sharedFolderId)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/list_folder_members", params: Sharing.ListFolderMembersArgsSerializer().serialize(request), responseSerializer: Sharing.SharedFolderMembersSerializer(), errorSerializer: Sharing.SharedFolderAccessErrorSerializer())
    }
    /**
        Once a cursor has been retrieved from listFolderMembers, use this to paginate through all shared folder members.
        Warning: This endpoint is in beta and is subject to minor but possibly backwards-incompatible changes.

        - parameter cursor: The cursor returned by your last call to listFolderMembers or listFolderMembersContinue.

         - returns: Through the response callback, the caller will receive a `Sharing.SharedFolderMembers` object on
        success or a `Sharing.ListFolderMembersContinueError` object on failure.
    */
    public func listFolderMembersContinue(cursor cursor: String) -> BabelRpcRequest<Sharing.SharedFolderMembersSerializer, Sharing.ListFolderMembersContinueErrorSerializer> {
        let request = Sharing.ListFolderMembersContinueArg(cursor: cursor)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/list_folder_members/continue", params: Sharing.ListFolderMembersContinueArgSerializer().serialize(request), responseSerializer: Sharing.SharedFolderMembersSerializer(), errorSerializer: Sharing.ListFolderMembersContinueErrorSerializer())
    }
    /**
        Share a folder with collaborators. Most sharing will be completed synchronously. Large folders will be completed
        asynchronously. To make testing the async case repeatable, set `ShareFolderArg.force_async`. If a asyncJobId in
        ShareFolderLaunch is returned, you'll need to call checkShareJobStatus until the action completes to get the
        metadata for the folder. Warning: This endpoint is in beta and is subject to minor but possibly
        backwards-incompatible changes.

        - parameter path: The path to the folder to share. If it does not exist, then a new one is created.
        - parameter memberPolicy: Who can be a member of this shared folder.
        - parameter aclUpdatePolicy: Who can add and remove members of this shared folder.
        - parameter sharedLinkPolicy: The policy to apply to shared links created for content inside this shared folder.
        - parameter forceAsync: Whether to force the share to happen asynchronously.

         - returns: Through the response callback, the caller will receive a `Sharing.ShareFolderLaunch` object on
        success or a `Sharing.ShareFolderError` object on failure.
    */
    public func shareFolder(path path: String, memberPolicy: Sharing.MemberPolicy = .Anyone, aclUpdatePolicy: Sharing.AclUpdatePolicy = .Owner, sharedLinkPolicy: Sharing.SharedLinkPolicy = .Anyone, forceAsync: Bool = false) -> BabelRpcRequest<Sharing.ShareFolderLaunchSerializer, Sharing.ShareFolderErrorSerializer> {
        let request = Sharing.ShareFolderArg(path: path, memberPolicy: memberPolicy, aclUpdatePolicy: aclUpdatePolicy, sharedLinkPolicy: sharedLinkPolicy, forceAsync: forceAsync)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/share_folder", params: Sharing.ShareFolderArgSerializer().serialize(request), responseSerializer: Sharing.ShareFolderLaunchSerializer(), errorSerializer: Sharing.ShareFolderErrorSerializer())
    }
    /**
        Returns the status of an asynchronous job for sharing a folder. Warning: This endpoint is in beta and is subject
        to minor but possibly backwards-incompatible changes.

        - parameter asyncJobId: Id of the asynchronous job. This is the value of a response returned from the method
        that launched the job.

         - returns: Through the response callback, the caller will receive a `Sharing.ShareFolderJobStatus` object on
        success or a `Async.PollError` object on failure.
    */
    public func checkShareJobStatus(asyncJobId asyncJobId: String) -> BabelRpcRequest<Sharing.ShareFolderJobStatusSerializer, Async.PollErrorSerializer> {
        let request = Async.PollArg(asyncJobId: asyncJobId)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/check_share_job_status", params: Async.PollArgSerializer().serialize(request), responseSerializer: Sharing.ShareFolderJobStatusSerializer(), errorSerializer: Async.PollErrorSerializer())
    }
    /**
        Returns the status of an asynchronous job. Warning: This endpoint is in beta and is subject to minor but
        possibly backwards-incompatible changes.

        - parameter asyncJobId: Id of the asynchronous job. This is the value of a response returned from the method
        that launched the job.

         - returns: Through the response callback, the caller will receive a `Sharing.JobStatus` object on success or a
        `Async.PollError` object on failure.
    */
    public func checkJobStatus(asyncJobId asyncJobId: String) -> BabelRpcRequest<Sharing.JobStatusSerializer, Async.PollErrorSerializer> {
        let request = Async.PollArg(asyncJobId: asyncJobId)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/check_job_status", params: Async.PollArgSerializer().serialize(request), responseSerializer: Sharing.JobStatusSerializer(), errorSerializer: Async.PollErrorSerializer())
    }
    /**
        Allows a shared folder owner to unshare the folder. You'll need to call checkJobStatus to determine if the
        action has completed successfully. Warning: This endpoint is in beta and is subject to minor but possibly
        backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.
        - parameter leaveACopy: If true, members of this shared folder will get a copy of this folder after it's
        unshared. Otherwise, it will be removed from their Dropbox. The current user, who is an owner, will always
        retain their copy.

         - returns: Through the response callback, the caller will receive a `Async.LaunchEmptyResult` object on success
        or a `Sharing.UnshareFolderError` object on failure.
    */
    public func unshareFolder(sharedFolderId sharedFolderId: String, leaveACopy: Bool) -> BabelRpcRequest<Async.LaunchEmptyResultSerializer, Sharing.UnshareFolderErrorSerializer> {
        let request = Sharing.UnshareFolderArg(sharedFolderId: sharedFolderId, leaveACopy: leaveACopy)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/unshare_folder", params: Sharing.UnshareFolderArgSerializer().serialize(request), responseSerializer: Async.LaunchEmptyResultSerializer(), errorSerializer: Sharing.UnshareFolderErrorSerializer())
    }
    /**
        Transfer ownership of a shared folder to a member of the shared folder. Warning: This endpoint is in beta and is
        subject to minor but possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.
        - parameter toDropboxId: A account or team member ID to transfer ownership to.

         - returns: Through the response callback, the caller will receive a `Void` object on success or a
        `Sharing.TransferFolderError` object on failure.
    */
    public func transferFolder(sharedFolderId sharedFolderId: String, toDropboxId: String) -> BabelRpcRequest<VoidSerializer, Sharing.TransferFolderErrorSerializer> {
        let request = Sharing.TransferFolderArg(sharedFolderId: sharedFolderId, toDropboxId: toDropboxId)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/transfer_folder", params: Sharing.TransferFolderArgSerializer().serialize(request), responseSerializer: Serialization._VoidSerializer, errorSerializer: Sharing.TransferFolderErrorSerializer())
    }
    /**
        Update the sharing policies for a shared folder. Warning: This endpoint is in beta and is subject to minor but
        possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.
        - parameter memberPolicy: Who can be a member of this shared folder. Only set this if the current user is on a
        team.
        - parameter aclUpdatePolicy: Who can add and remove members of this shared folder.
        - parameter sharedLinkPolicy: The policy to apply to shared links created for content inside this shared folder.

         - returns: Through the response callback, the caller will receive a `Sharing.SharedFolderMetadata` object on
        success or a `Sharing.UpdateFolderPolicyError` object on failure.
    */
    public func updateFolderPolicy(sharedFolderId sharedFolderId: String, memberPolicy: Sharing.MemberPolicy? = nil, aclUpdatePolicy: Sharing.AclUpdatePolicy? = nil, sharedLinkPolicy: Sharing.SharedLinkPolicy? = nil) -> BabelRpcRequest<Sharing.SharedFolderMetadataSerializer, Sharing.UpdateFolderPolicyErrorSerializer> {
        let request = Sharing.UpdateFolderPolicyArg(sharedFolderId: sharedFolderId, memberPolicy: memberPolicy, aclUpdatePolicy: aclUpdatePolicy, sharedLinkPolicy: sharedLinkPolicy)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/update_folder_policy", params: Sharing.UpdateFolderPolicyArgSerializer().serialize(request), responseSerializer: Sharing.SharedFolderMetadataSerializer(), errorSerializer: Sharing.UpdateFolderPolicyErrorSerializer())
    }
    /**
        Allows an owner or editor (if the ACL update policy allows) of a shared folder to add another member. For the
        new member to get access to all the functionality for this folder, you will need to call mountFolder on their
        behalf. Warning: This endpoint is in beta and is subject to minor but possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.
        - parameter members: The intended list of members to add.  Added members will receive invites to join the shared
        folder.
        - parameter quiet: Whether added members should be notified via email and device notifications of their invite.
        - parameter customMessage: Optional message to display to added members in their invitation.

         - returns: Through the response callback, the caller will receive a `Void` object on success or a
        `Sharing.AddFolderMemberError` object on failure.
    */
    public func addFolderMember(sharedFolderId sharedFolderId: String, members: Array<Sharing.AddMember>, quiet: Bool = false, customMessage: String? = nil) -> BabelRpcRequest<VoidSerializer, Sharing.AddFolderMemberErrorSerializer> {
        let request = Sharing.AddFolderMemberArg(sharedFolderId: sharedFolderId, members: members, quiet: quiet, customMessage: customMessage)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/add_folder_member", params: Sharing.AddFolderMemberArgSerializer().serialize(request), responseSerializer: Serialization._VoidSerializer, errorSerializer: Sharing.AddFolderMemberErrorSerializer())
    }
    /**
        Allows an owner or editor (if the ACL update policy allows) of a shared folder to remove another member.
        Warning: This endpoint is in beta and is subject to minor but possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.
        - parameter member: The member to remove from the folder.
        - parameter leaveACopy: If true, the removed user will keep their copy of the folder after it's unshared,
        assuming it was mounted. Otherwise, it will be removed from their Dropbox. Also, this must be set to false when
        kicking a group.

         - returns: Through the response callback, the caller will receive a `Async.LaunchEmptyResult` object on success
        or a `Sharing.RemoveFolderMemberError` object on failure.
    */
    public func removeFolderMember(sharedFolderId sharedFolderId: String, member: Sharing.MemberSelector, leaveACopy: Bool) -> BabelRpcRequest<Async.LaunchEmptyResultSerializer, Sharing.RemoveFolderMemberErrorSerializer> {
        let request = Sharing.RemoveFolderMemberArg(sharedFolderId: sharedFolderId, member: member, leaveACopy: leaveACopy)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/remove_folder_member", params: Sharing.RemoveFolderMemberArgSerializer().serialize(request), responseSerializer: Async.LaunchEmptyResultSerializer(), errorSerializer: Sharing.RemoveFolderMemberErrorSerializer())
    }
    /**
        Allows an owner or editor of a shared folder to update another member's permissions. Warning: This endpoint is
        in beta and is subject to minor but possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.
        - parameter member: The member of the shared folder to update.  Only the dropboxId in MemberSelector may be set
        at this time.
        - parameter accessLevel: The new access level for member. owner in AccessLevel is disallowed.

         - returns: Through the response callback, the caller will receive a `Void` object on success or a
        `Sharing.UpdateFolderMemberError` object on failure.
    */
    public func updateFolderMember(sharedFolderId sharedFolderId: String, member: Sharing.MemberSelector, accessLevel: Sharing.AccessLevel) -> BabelRpcRequest<VoidSerializer, Sharing.UpdateFolderMemberErrorSerializer> {
        let request = Sharing.UpdateFolderMemberArg(sharedFolderId: sharedFolderId, member: member, accessLevel: accessLevel)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/update_folder_member", params: Sharing.UpdateFolderMemberArgSerializer().serialize(request), responseSerializer: Serialization._VoidSerializer, errorSerializer: Sharing.UpdateFolderMemberErrorSerializer())
    }
    /**
        The current user mounts the designated folder. Mount a shared folder for a user after they have been added as a
        member. Once mounted, the shared folder will appear in their Dropbox. Warning: This endpoint is in beta and is
        subject to minor but possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID of the shared folder to mount.

         - returns: Through the response callback, the caller will receive a `Sharing.SharedFolderMetadata` object on
        success or a `Sharing.MountFolderError` object on failure.
    */
    public func mountFolder(sharedFolderId sharedFolderId: String) -> BabelRpcRequest<Sharing.SharedFolderMetadataSerializer, Sharing.MountFolderErrorSerializer> {
        let request = Sharing.MountFolderArg(sharedFolderId: sharedFolderId)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/mount_folder", params: Sharing.MountFolderArgSerializer().serialize(request), responseSerializer: Sharing.SharedFolderMetadataSerializer(), errorSerializer: Sharing.MountFolderErrorSerializer())
    }
    /**
        The current user unmounts the designated folder. They can re-mount the folder at a later time using mountFolder.
        Warning: This endpoint is in beta and is subject to minor but possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.

         - returns: Through the response callback, the caller will receive a `Void` object on success or a
        `Sharing.UnmountFolderError` object on failure.
    */
    public func unmountFolder(sharedFolderId sharedFolderId: String) -> BabelRpcRequest<VoidSerializer, Sharing.UnmountFolderErrorSerializer> {
        let request = Sharing.UnmountFolderArg(sharedFolderId: sharedFolderId)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/unmount_folder", params: Sharing.UnmountFolderArgSerializer().serialize(request), responseSerializer: Serialization._VoidSerializer, errorSerializer: Sharing.UnmountFolderErrorSerializer())
    }
    /**
        The current user relinquishes their membership in the designated shared folder and will no longer have access to
        the folder.  A folder owner cannot relinquish membership in their own folder. Warning: This endpoint is in beta
        and is subject to minor but possibly backwards-incompatible changes.

        - parameter sharedFolderId: The ID for the shared folder.

         - returns: Through the response callback, the caller will receive a `Void` object on success or a
        `Sharing.RelinquishFolderMembershipError` object on failure.
    */
    public func relinquishFolderMembership(sharedFolderId sharedFolderId: String) -> BabelRpcRequest<VoidSerializer, Sharing.RelinquishFolderMembershipErrorSerializer> {
        let request = Sharing.RelinquishFolderMembershipArg(sharedFolderId: sharedFolderId)
        return BabelRpcRequest(client: self.client, host: "meta", route: "/sharing/relinquish_folder_membership", params: Sharing.RelinquishFolderMembershipArgSerializer().serialize(request), responseSerializer: Serialization._VoidSerializer, errorSerializer: Sharing.RelinquishFolderMembershipErrorSerializer())
    }
}
