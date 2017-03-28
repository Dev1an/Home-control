//
//  mpv Event.swift
//  Radio
//
//  Created by Damiaan on 28/03/17.
//
//

enum Event: UInt32 {
	/**
	* Nothing happened. Happens on timeouts or sporadic wakeups.
	*/
	case NONE              = 0,
	/**
	* Happens when the player quits. The player enters a state where it tries
	* to disconnect all clients. Most requests to the player will fail, and
	* mpv_wait_event() will always return instantly (returning new shutdown
	* events if no other events are queued). The client should react to this
	* and quit with mpv_detach_destroy() as soon as possible.
	*/
	SHUTDOWN          = 1,
	/**
	* See mpv_request_log_messages().
	*/
	LOG_MESSAGE       = 2,
	/**
	* Reply to a mpv_get_property_async() request.
	* See also mpv_event and property.
	*/
	GET_PROPERTY_REPLY = 3,
	/**
	* Reply to a mpv_set_property_async() request.
	* (Unlike GET_PROPERTY, property is not used.)
	*/
	SET_PROPERTY_REPLY = 4,
	/**
	* Reply to a mpv_command_async() request.
	*/
	COMMAND_REPLY     = 5,
	/**
	* Notification before playback start of a file (before the file is loaded).
	*/
	START_FILE        = 6,
	/**
	* Notification after playback end (after the file was unloaded).
	* See also mpv_event and end_file.
	*/
	END_FILE          = 7,
	/**
	* Notification when the file has been loaded (headers were read etc.), and
	* decoding starts.
	*/
	FILE_LOADED       = 8,
	/**
	* The list of video/audio/subtitle tracks was changed. (E.g. a new track
	* was found. This doesn't necessarily indicate a track switch; for this,
	* TRACK_SWITCHED is used.)
	*
	* @deprecated This is equivalent to using mpv_observe_property() on the
	*             "track-list" property. The event is redundant, and might
	*             be removed in the far future.
	*/
	TRACKS_CHANGED    = 9,
	/**
	* A video/audio/subtitle track was switched on or off.
	*
	* @deprecated This is equivalent to using mpv_observe_property() on the
	*             "vid", "aid", and "sid" properties. The event is redundant,
	*             and might be removed in the far future.
	*/
	TRACK_SWITCHED    = 10,
	/**
	* Idle mode was entered. In this mode, no file is played, and the playback
	* core waits for new commands. (The command line player normally quits
	* instead of entering idle mode, unless --idle was specified. If mpv
	* was started with mpv_create(), idle mode is enabled by default.)
	*/
	IDLE              = 11,
	/**
	* Playback was paused. This indicates the user pause state.
	*
	* The user pause state is the state the user requested (changed with the
	* "pause" property). There is an internal pause state too, which is entered
	* if e.g. the network is too slow (the "core-idle" property generally
	* indicates whether the core is playing or waiting).
	*
	* This event is sent whenever any pause states change, not only the user
	* state. You might get multiple events in a row while these states change
	* independently. But the event ID sent always indicates the user pause
	* state.
	*
	* If you don't want to deal with this, use mpv_observe_property() on the
	* "pause" property and ignore PAUSE/UNPAUSE. Likewise, the
	* "core-idle" property tells you whether video is actually playing or not.
	*
	* @deprecated The event is redundant with mpv_observe_property() as
	*             mentioned above, and might be removed in the far future.
	*/
	PAUSE             = 12,
	/**
	* Playback was unpaused. See PAUSE for not so obvious details.
	*
	* @deprecated The event is redundant with mpv_observe_property() as
	*             explained in the PAUSE comments, and might be
	*             removed in the far future.
	*/
	UNPAUSE           = 13,
	/**
	* Sent every time after a video frame is displayed. Note that currently,
	* this will be sent in lower frequency if there is no video, or playback
	* is paused - but that will be removed in the future, and it will be
	* restricted to video frames only.
	*/
	TICK              = 14,
	/**
	* @deprecated This was used internally with the internal "script_dispatch"
	*             command to dispatch keyboard and mouse input for the OSC.
	*             It was never useful in general and has been completely
	*             replaced with "script_binding".
	*             This event never happens anymore, and is included in this
	*             header only for compatibility.
	*/
	SCRIPT_INPUT_DISPATCH = 15,
	/**
	* Triggered by the script_message input command. The command uses the
	* first argument of the command as client name (see mpv_client_name()) to
	* dispatch the message, and passes along all arguments starting from the
	* second argument as strings.
	* See also mpv_event and client_message.
	*/
	CLIENT_MESSAGE    = 16,
	/**
	* Happens after video changed in some way. This can happen on resolution
	* changes, pixel format changes, or video filter changes. The event is
	* sent after the video filters and the VO are reconfigured. Applications
	* embedding a mpv window should listen to this event in order to resize
	* the window if needed.
	* Note that this event can happen sporadically, and you should check
	* yourself whether the video parameters really changed before doing
	* something expensive.
	*/
	VIDEO_RECONFIG    = 17,
	/**
	* Similar to VIDEO_RECONFIG. This is relatively uninteresting,
	* because there is no such thing as audio output embedding.
	*/
	AUDIO_RECONFIG    = 18,
	/**
	* Happens when metadata (like file tags) is possibly updated. (It's left
	* unspecified whether this happens on file start or only when it changes
	* within a file.)
	*
	* @deprecated This is equivalent to using mpv_observe_property() on the
	*             "metadata" property. The event is redundant, and might
	*             be removed in the far future.
	*/
	METADATA_UPDATE   = 19,
	/**
	* Happens when a seek was initiated. Playback stops. Usually it will
	* resume with PLAYBACK_RESTART as soon as the seek is finished.
	*/
	SEEK              = 20,
	/**
	* There was a discontinuity of some sort (like a seek), and playback
	* was reinitialized. Usually happens after seeking, or ordered chapter
	* segment switches. The main purpose is allowing the client to detect
	* when a seek request is finished.
	*/
	PLAYBACK_RESTART  = 21,
	/**
	* Event sent due to mpv_observe_property().
	* See also mpv_event and property.
	*/
	PROPERTY_CHANGE   = 22,
	/**
	* Happens when the current chapter changes.
	*
	* @deprecated This is equivalent to using mpv_observe_property() on the
	*             "chapter" property. The event is redundant, and might
	*             be removed in the far future.
	*/
	CHAPTER_CHANGE    = 23,
	/**
	* Happens if the internal per-mpv_handle ringbuffer overflows, and at
	* least 1 event had to be dropped. This can happen if the client doesn't
	* read the event queue quickly enough with mpv_wait_event(), or if the
	* client makes a very large number of asynchronous calls at once.
	*
	* Event delivery will continue normally once this event was returned
	* (this forces the client to empty the queue completely).
	*/
	QUEUE_OVERFLOW    = 24
	// Internal note: adjust INTERNAL_EVENT_BASE when adding new events.
}
