///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation

/// Routes for the team_log namespace
/// For Objective-C compatible routes see DBTeamLogRoutes
public class TeamLogRoutes: DropboxTransportClientOwning {
    public let client: DropboxTransportClient
    required init(client: DropboxTransportClient) {
        self.client = client
    }

    /// Retrieves team events. If the result's hasMore in GetTeamEventsResult field is true, call getEventsContinue with
    /// the returned cursor to retrieve more entries. If end_time is not specified in your request, you may use the
    /// returned cursor to poll getEventsContinue for new events. Many attributes note 'may be missing due to
    /// historical data gap'. Note that the file_operations category and & analogous paper events are not available
    /// on all Dropbox Business plans /business/plans-comparison. Use features/get_values
    /// /developers/documentation/http/teams#team-features-get_values to check for this feature. Permission : Team
    /// Auditing.
    ///
    /// - scope: events.read
    ///
    /// - parameter limit: The maximal number of results to return per call. Note that some calls may not return limit
    /// number of events, and may even return no events, even with `has_more` set to true. In this case, callers
    /// should fetch again using getEventsContinue.
    /// - parameter accountId: Filter the events by account ID. Return only events with this account_id as either Actor,
    /// Context, or Participants.
    /// - parameter time: Filter by time range.
    /// - parameter category: Filter the returned events to a single category. Note that category shouldn't be provided
    /// together with event_type.
    /// - parameter eventType: Filter the returned events to a single event type. Note that event_type shouldn't be
    /// provided together with category.
    ///
    /// - returns: Through the response callback, the caller will receive a `TeamLog.GetTeamEventsResult` object on
    /// success or a `TeamLog.GetTeamEventsError` object on failure.
    @discardableResult public func getEvents(
        limit: UInt32 = 1_000,
        accountId: String? = nil,
        time: TeamCommon.TimeRange? = nil,
        category: TeamLog.EventCategory? = nil,
        eventType: TeamLog.EventTypeArg? = nil
    ) -> RpcRequest<TeamLog.GetTeamEventsResultSerializer, TeamLog.GetTeamEventsErrorSerializer> {
        let route = TeamLog.getEvents
        let serverArgs = TeamLog.GetTeamEventsArg(limit: limit, accountId: accountId, time: time, category: category, eventType: eventType)
        return client.request(route, serverArgs: serverArgs)
    }

    /// Once a cursor has been retrieved from getEvents, use this to paginate through all events. Permission : Team
    /// Auditing.
    ///
    /// - scope: events.read
    ///
    /// - parameter cursor: Indicates from what point to get the next set of events.
    ///
    /// - returns: Through the response callback, the caller will receive a `TeamLog.GetTeamEventsResult` object on
    /// success or a `TeamLog.GetTeamEventsContinueError` object on failure.
    @discardableResult public func getEventsContinue(cursor: String)
        -> RpcRequest<TeamLog.GetTeamEventsResultSerializer, TeamLog.GetTeamEventsContinueErrorSerializer> {
        let route = TeamLog.getEventsContinue
        let serverArgs = TeamLog.GetTeamEventsContinueArg(cursor: cursor)
        return client.request(route, serverArgs: serverArgs)
    }
}
