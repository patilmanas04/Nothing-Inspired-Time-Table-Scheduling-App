import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../models/time_slot.dart';
import '../theme/nothing_theme.dart';
import '../widgets/nothing_widgets.dart';

class EditScheduleScreen extends StatefulWidget {
  const EditScheduleScreen({super.key});

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT SCHEDULE'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: NothingTheme.red),
            onPressed: () => _showAddSlotDialog(context, _tabController.index + 1),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: NothingTheme.red,
          unselectedLabelColor: NothingTheme.grey,
          indicatorColor: NothingTheme.red,
          labelStyle: GoogleFonts.jetBrainsMono(
            textStyle: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16),
          ),
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: List.generate(7, (index) => _DayScheduleView(dayOfWeek: index + 1)),
        ),
    );
  }

  void _showAddSlotDialog(BuildContext context, int dayOfWeek) {
    showDialog(
      context: context,

      builder: (context) => _SlotDialog(dayOfWeek: dayOfWeek),
    );
  }
}

class _DayScheduleView extends StatelessWidget {
  final int dayOfWeek;

  const _DayScheduleView({required this.dayOfWeek});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final slots = storage.getSlotsForDay(dayOfWeek);

    if (slots.isEmpty) {
      return Center(
        child: Text(
          'NO SLOTS',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: NothingTheme.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 120),
      itemCount: slots.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final containerColor = isDark ? NothingTheme.white : NothingTheme.black;
        final contentColor = isDark ? NothingTheme.black : NothingTheme.white;

        return MatrixCard(
          onTap: () => _showEditSlotDialog(context, slot),
          child: Row(
            children: [
              if (slot.iconCode != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    IconData(slot.iconCode!, fontFamily: 'MaterialIcons'),
                    color: contentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      color: containerColor,
                      child: Text(
                        '${_formatTime(slot.startMinutes)} - ${_formatTime(slot.endMinutes)}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: contentColor,
                              fontSize: 12,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slot.title.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: NothingTheme.red),
                onPressed: () => storage.deleteTimeSlot(slot.id),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditSlotDialog(BuildContext context, TimeSlot slot) {
    showDialog(
      context: context,

      builder: (context) => _SlotDialog(dayOfWeek: dayOfWeek, slot: slot),
    );
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} $ampm';
  }
}

class _SlotDialog extends StatefulWidget {
  final int dayOfWeek;
  final TimeSlot? slot;

  const _SlotDialog({required this.dayOfWeek, this.slot});

  @override
  State<_SlotDialog> createState() => _SlotDialogState();
}

class _SlotDialogState extends State<_SlotDialog> {
  late TextEditingController _titleController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  int? _selectedIconCode;

  // Initial visible icons (subset of all icons)
  List<IconData> _visibleIcons = [
    Icons.work_outline,
    Icons.school_outlined,
    Icons.fitness_center_outlined,
    Icons.code,
    Icons.book_outlined,
  ];

  // Comprehensive list of icons for the extended dialog
  final List<IconData> _allIcons = [
    // General
    Icons.work_outline, Icons.school_outlined, Icons.fitness_center_outlined, Icons.code,
    Icons.book_outlined, Icons.coffee_outlined, Icons.bed_outlined, Icons.home_outlined,
    Icons.shopping_cart_outlined, Icons.restaurant_outlined, Icons.computer, Icons.music_note_outlined,
    Icons.movie_outlined, Icons.gamepad_outlined, Icons.directions_run, Icons.directions_bike,
    Icons.directions_car_outlined, Icons.flight_outlined, Icons.local_hospital_outlined, Icons.attach_money,
    // Extended
    Icons.account_balance_outlined, Icons.account_circle_outlined, Icons.alarm, Icons.analytics_outlined,
    Icons.anchor, Icons.android, Icons.apartment, Icons.api, Icons.architecture, Icons.archive_outlined,
    Icons.article_outlined, Icons.assignment_outlined, Icons.auto_stories_outlined, Icons.backpack_outlined,
    Icons.badge_outlined, Icons.bakery_dining_outlined, Icons.balance, Icons.beach_access_outlined,
    Icons.bolt, Icons.brush_outlined, Icons.bug_report_outlined, Icons.build_outlined, Icons.business_center_outlined,
    Icons.cake_outlined, Icons.calculate_outlined, Icons.calendar_month_outlined, Icons.camera_alt_outlined,
    Icons.campaign_outlined, Icons.card_giftcard, Icons.celebration_outlined,
    Icons.chair_outlined, Icons.checkroom_outlined, Icons.child_care_outlined, Icons.church_outlined,
    Icons.cleaning_services_outlined, Icons.cloud_outlined, Icons.comment_outlined, Icons.commute_outlined,
    Icons.construction_outlined, Icons.content_cut, Icons.cookie_outlined, Icons.cottage_outlined,
    Icons.credit_card_outlined, Icons.crop_outlined, Icons.currency_bitcoin, Icons.dark_mode_outlined,
    Icons.dashboard_outlined, Icons.data_object, Icons.delete_outline, Icons.delivery_dining_outlined,
    Icons.design_services_outlined, Icons.devices_outlined, Icons.diamond_outlined, Icons.dns_outlined,
    Icons.done_all, Icons.draw_outlined, Icons.dry_cleaning_outlined, Icons.eco_outlined,
    Icons.edit_note, Icons.electric_bolt, Icons.electric_car_outlined, Icons.emoji_events_outlined,
    Icons.emoji_food_beverage_outlined, Icons.emoji_objects_outlined, Icons.engineering_outlined,
    Icons.euro_symbol, Icons.event_seat_outlined, Icons.explore_outlined, Icons.extension_outlined,
    Icons.face_outlined, Icons.fastfood_outlined, Icons.favorite_outline, Icons.festival_outlined,
    Icons.filter_hdr_outlined, Icons.fingerprint, Icons.fire_extinguisher, Icons.fireplace_outlined,
    Icons.flag_outlined, Icons.flashlight_on_outlined, Icons.flatware_outlined, Icons.flight_takeoff,
    Icons.flip_camera_android_outlined, Icons.folder_open_outlined, Icons.forest_outlined, Icons.format_paint_outlined,
    Icons.forum_outlined, Icons.g_translate, Icons.garage_outlined, Icons.gavel_outlined,
    Icons.gesture_outlined, Icons.gif_box_outlined, Icons.golf_course_outlined, Icons.grass_outlined,
    Icons.group_outlined, Icons.handyman_outlined, Icons.headphones_outlined, Icons.health_and_safety_outlined,
    Icons.hiking_outlined, Icons.history_edu_outlined, Icons.hotel_outlined, Icons.hourglass_empty,
    Icons.icecream_outlined, Icons.image_outlined, Icons.inbox_outlined, Icons.inventory_2_outlined,
    Icons.ios_share, Icons.iron_outlined, Icons.kayaking_outlined, Icons.keyboard_outlined,
    Icons.kitchen_outlined, Icons.label_outlined, Icons.landscape_outlined, Icons.language_outlined,
    Icons.laptop_chromebook_outlined, Icons.layers_outlined, Icons.library_books_outlined, Icons.light_mode_outlined,
    Icons.lightbulb_outline, Icons.liquor_outlined, Icons.local_activity_outlined, Icons.local_airport_outlined,
    Icons.local_atm_outlined, Icons.local_bar_outlined, Icons.local_cafe_outlined, Icons.local_car_wash_outlined,
    Icons.local_convenience_store_outlined, Icons.local_dining_outlined, Icons.local_drink_outlined,
    Icons.local_fire_department_outlined, Icons.local_florist_outlined, Icons.local_gas_station_outlined,
    Icons.local_grocery_store_outlined, Icons.local_laundry_service_outlined, Icons.local_library_outlined,
    Icons.local_mall_outlined, Icons.local_movies_outlined, Icons.local_offer_outlined, Icons.local_parking_outlined,
    Icons.local_pharmacy_outlined, Icons.local_pizza_outlined, Icons.local_police_outlined, Icons.local_post_office_outlined,
    Icons.local_printshop_outlined, Icons.local_shipping_outlined, Icons.local_taxi_outlined, Icons.location_city_outlined,
    Icons.location_on_outlined, Icons.lock_outline, Icons.login_outlined, Icons.logout_outlined,
    Icons.looks_outlined, Icons.loop_outlined, Icons.lunch_dining_outlined, Icons.map_outlined,
    Icons.masks_outlined, Icons.maximize, Icons.medical_services_outlined, Icons.medication_outlined,
    Icons.meeting_room_outlined, Icons.memory_outlined, Icons.menu_book_outlined, Icons.mic_outlined,
    Icons.microwave_outlined, Icons.military_tech_outlined, Icons.minimize, Icons.miscellaneous_services_outlined,
    Icons.mode_night_outlined, Icons.monitor_heart_outlined, Icons.moped_outlined, Icons.more_horiz,
    Icons.mosque_outlined, Icons.mouse_outlined, Icons.museum_outlined, Icons.nightlife_outlined,
    Icons.nightlight_outlined, Icons.no_food_outlined, Icons.notifications_outlined, Icons.oil_barrel_outlined,
    Icons.ondemand_video_outlined, Icons.palette_outlined, Icons.park_outlined, Icons.payments_outlined,
    Icons.pedal_bike_outlined, Icons.people_outline, Icons.percent, Icons.person_outline,
    Icons.pets_outlined, Icons.phone_android_outlined, Icons.photo_camera_outlined, Icons.piano_outlined,
    Icons.pin_drop_outlined, Icons.place_outlined, Icons.plumbing_outlined, Icons.podcasts_outlined,
    Icons.pool_outlined, Icons.power_outlined, Icons.precision_manufacturing_outlined, Icons.pregnant_woman_outlined,
    Icons.print_outlined, Icons.psychology_outlined, Icons.public_outlined, Icons.push_pin_outlined,
    Icons.qr_code_2, Icons.question_mark_outlined, Icons.radio_outlined, Icons.ramen_dining_outlined,
    Icons.rate_review_outlined, Icons.receipt_long_outlined, Icons.recycling_outlined, Icons.redeem_outlined,
    Icons.remove_red_eye_outlined, Icons.restaurant_menu_outlined, Icons.rocket_launch_outlined, Icons.roller_skating_outlined,
    Icons.room_service_outlined, Icons.router_outlined, Icons.rowing_outlined, Icons.rss_feed,
    Icons.rtt_outlined, Icons.run_circle_outlined, Icons.rv_hookup_outlined, Icons.sailing_outlined,
    Icons.sanitizer_outlined, Icons.satellite_alt_outlined, Icons.save_alt, Icons.savings_outlined,
    Icons.scanner_outlined, Icons.schedule_outlined, Icons.science_outlined, Icons.score_outlined,
    Icons.screen_search_desktop_outlined, Icons.search_outlined, Icons.security_outlined, Icons.sell_outlined,
    Icons.send_outlined, Icons.sensors_outlined, Icons.settings_outlined, Icons.share_outlined,
    Icons.shield_outlined, Icons.shopping_bag_outlined, Icons.shopping_basket_outlined, Icons.shower_outlined,
    Icons.shuffle_outlined, Icons.signpost_outlined, Icons.sim_card_outlined, Icons.skateboarding_outlined,
    Icons.smart_button_outlined, Icons.smart_display_outlined, Icons.smart_screen_outlined, Icons.smart_toy_outlined,
    Icons.smartphone_outlined, Icons.smoke_free_outlined, Icons.smoking_rooms_outlined, Icons.snowboarding_outlined,
    Icons.snowmobile_outlined, Icons.snowshoeing_outlined, Icons.soap_outlined, Icons.social_distance_outlined,
    Icons.solar_power_outlined, Icons.soup_kitchen_outlined, Icons.spa_outlined, Icons.speaker_outlined,
    Icons.speed_outlined, Icons.sports_bar_outlined, Icons.sports_baseball_outlined, Icons.sports_basketball_outlined,
    Icons.sports_cricket_outlined, Icons.sports_esports_outlined, Icons.sports_football_outlined, Icons.sports_golf_outlined,
    Icons.sports_gymnastics_outlined, Icons.sports_handball_outlined, Icons.sports_hockey_outlined, Icons.sports_kabaddi_outlined,
    Icons.sports_martial_arts_outlined, Icons.sports_mma_outlined, Icons.sports_motorsports_outlined, Icons.sports_rugby_outlined,
    Icons.sports_soccer_outlined, Icons.sports_tennis_outlined, Icons.sports_volleyball_outlined, Icons.square_foot_outlined,
    Icons.stacked_line_chart_outlined, Icons.stadium_outlined, Icons.stairs_outlined, Icons.star_outline,
    Icons.store_mall_directory_outlined, Icons.storefront_outlined, Icons.storm_outlined, Icons.straighten_outlined,
    Icons.stream_outlined, Icons.streetview_outlined, Icons.stroller_outlined, Icons.style_outlined,
    Icons.subway_outlined, Icons.sunny, Icons.support_agent_outlined, Icons.surfing_outlined,
    Icons.swipe_outlined, Icons.synagogue_outlined, Icons.sync_alt, Icons.system_update_alt,
    Icons.tab_outlined, Icons.table_bar_outlined, Icons.table_restaurant_outlined, Icons.tablet_android_outlined,
    Icons.tag_outlined, Icons.takeout_dining_outlined, Icons.task_alt, Icons.taxi_alert_outlined,
    Icons.temple_buddhist_outlined, Icons.temple_hindu_outlined, Icons.terminal_outlined, Icons.terrain_outlined,
    Icons.text_snippet_outlined, Icons.theater_comedy_outlined, Icons.thermostat_outlined, Icons.thumb_up_alt_outlined,
    Icons.timer_outlined, Icons.tips_and_updates_outlined, Icons.tire_repair_outlined, Icons.toll_outlined,
    Icons.tonality_outlined, Icons.topic_outlined, Icons.tornado_outlined, Icons.touch_app_outlined,
    Icons.tour_outlined, Icons.toys_outlined, Icons.traffic_outlined, Icons.train_outlined,
    Icons.tram_outlined, Icons.transfer_within_a_station_outlined, Icons.transform_outlined, Icons.transit_enterexit_outlined,
    Icons.translate_outlined, Icons.travel_explore_outlined, Icons.trending_up, Icons.trip_origin,
    Icons.trolley, Icons.two_wheeler_outlined, Icons.umbrella_outlined, Icons.usb_outlined,
    Icons.vaccines_outlined, Icons.vape_free_outlined, Icons.vaping_rooms_outlined, Icons.verified_user_outlined,
    Icons.vertical_split_outlined, Icons.vibration_outlined, Icons.video_camera_back_outlined, Icons.video_chat_outlined,
    Icons.video_label_outlined, Icons.video_library_outlined, Icons.videogame_asset_outlined, Icons.view_agenda_outlined,
    Icons.view_array_outlined, Icons.view_carousel_outlined, Icons.view_column_outlined, Icons.view_comfy_outlined,
    Icons.view_compact_outlined, Icons.view_cozy_outlined, Icons.view_day_outlined, Icons.view_headline_outlined,
    Icons.view_in_ar_outlined, Icons.view_kanban_outlined, Icons.view_list_outlined, Icons.view_module_outlined,
    Icons.view_quilt_outlined, Icons.view_sidebar_outlined, Icons.view_stream_outlined, Icons.view_timeline_outlined,
    Icons.view_week_outlined, Icons.villa_outlined, Icons.visibility_outlined, Icons.voice_chat_outlined,
    Icons.voicemail_outlined, Icons.volume_up_outlined, Icons.volunteer_activism_outlined, Icons.vpn_key_outlined,
    Icons.vrpano_outlined, Icons.wallet_outlined, Icons.wallpaper_outlined, Icons.warehouse_outlined,
    Icons.warning_amber_outlined, Icons.wash_outlined, Icons.watch_outlined, Icons.water_damage_outlined,
    Icons.water_drop_outlined, Icons.waterfall_chart_outlined, Icons.waves_outlined, Icons.wb_sunny_outlined,
    Icons.wc_outlined, Icons.web_outlined, Icons.webhook_outlined, Icons.weekend_outlined,
    Icons.west_outlined, Icons.whatshot_outlined, Icons.wheelchair_pickup_outlined, Icons.wifi_outlined,
    Icons.wifi_calling_3_outlined, Icons.wifi_channel_outlined, Icons.wifi_find_outlined, Icons.wifi_password_outlined,
    Icons.wifi_protected_setup_outlined, Icons.wifi_tethering_outlined, Icons.window_outlined, Icons.wine_bar_outlined,
    Icons.woman_outlined, Icons.work_history_outlined, Icons.workspace_premium_outlined, Icons.workspaces_outlined,
    Icons.wrap_text_outlined, Icons.wrong_location_outlined, Icons.wysiwyg_outlined, Icons.yard_outlined,
    Icons.youtube_searched_for_outlined, Icons.zoom_in_outlined, Icons.zoom_out_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.slot?.title ?? '');
    
    // Remove the last icon to make room for the Edit button (Replace logic)
    // if (_visibleIcons.isNotEmpty) {
    //   _visibleIcons.removeLast();
    // }

    if (widget.slot != null) {
      _startTime = TimeOfDay(hour: widget.slot!.startMinutes ~/ 60, minute: widget.slot!.startMinutes % 60);
      _endTime = TimeOfDay(hour: widget.slot!.endMinutes ~/ 60, minute: widget.slot!.endMinutes % 60);
      _selectedIconCode = widget.slot!.iconCode;
      
      // If the selected icon is not in the visible list (but is in all icons), add it
      if (_selectedIconCode != null) {
        final isVisible = _visibleIcons.any((icon) => icon.codePoint == _selectedIconCode);
        if (!isVisible) {
          final icon = _allIcons.firstWhere(
            (icon) => icon.codePoint == _selectedIconCode,
            orElse: () => Icons.error_outline,
          );
          if (icon != Icons.error_outline) {
            _visibleIcons.insert(0, icon);
          }
        }
      }
    } else {
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.slot != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final backgroundColor = isDark ? const Color(0xFF1A1A1A) : NothingTheme.white;
    final inverseBgColor = textColor;
    final inverseTextColor = isDark ? NothingTheme.black : NothingTheme.white;

    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(isEditing ? 'EDIT SLOT' : 'ADD SLOT', style: Theme.of(context).textTheme.displaySmall),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'TITLE',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeButton(
                  context,
                  'START: ${_startTime.format(context)}',
                  () async {
                    final time = await _showCustomTimePicker(context, _startTime);
                    if (time != null) setState(() => _startTime = time);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeButton(
                  context,
                  'END: ${_endTime.format(context)}',
                  () async {
                    final time = await _showCustomTimePicker(context, _endTime);
                    if (time != null) setState(() => _endTime = time);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.maxFinite,
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _visibleIcons.length + 1, // +1 for the Edit button
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == _visibleIcons.length) {
                  // Edit Button
                  return Material(
                    color: inverseBgColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => _showExtendedIconDialog(context),
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.edit,
                          size: 20,
                          color: inverseTextColor,
                        ),
                      ),
                    ),
                  );
                }

                final icon = _visibleIcons[index];
                final isSelected = _selectedIconCode == icon.codePoint;
                return Material(
                  color: isSelected ? inverseBgColor : backgroundColor,
                  shape: CircleBorder(side: BorderSide(color: textColor)),
                  child: InkWell(
                    onTap: () => setState(() => _selectedIconCode = icon.codePoint),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected ? inverseTextColor : textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.getFont('JetBrains Mono', color: NothingTheme.grey, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 4), // Reduced spacing
            TextButton(
              onPressed: () {
                if (_titleController.text.isEmpty) return;
                final start = _startTime.hour * 60 + _startTime.minute;
                final end = _endTime.hour * 60 + _endTime.minute;
                
                if (end <= start) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('End time must be after start time')),
                  );
                  return;
                }

                final slot = TimeSlot(
                  id: widget.slot?.id ?? DateTime.now().toString(), // Use existing ID if editing
                  title: _titleController.text,
                  startMinutes: start,
                  endMinutes: end,
                  dayOfWeek: widget.dayOfWeek,
                  iconCode: _selectedIconCode,
                );
                
                Provider.of<StorageService>(context, listen: false).addTimeSlot(slot);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: inverseBgColor,
                foregroundColor: inverseTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(120, 48),
              ),
              child: Text(
                isEditing ? 'UPDATE' : 'ADD',
                style: GoogleFonts.getFont('JetBrains Mono', fontWeight: FontWeight.bold),
              ),
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildTimeButton(BuildContext context, String text, VoidCallback onPressed) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: textColor),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.getFont(
            'JetBrains Mono',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Future<TimeOfDay?> _showCustomTimePicker(BuildContext context, TimeOfDay initialTime) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      barrierColor: Colors.transparent,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: GoogleFonts.getFont('JetBrains Mono', fontWeight: FontWeight.bold),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A1A)
                  : NothingTheme.white,
              confirmButtonStyle: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).brightness == Brightness.dark ? NothingTheme.white : NothingTheme.black
                ),
                foregroundColor: MaterialStateProperty.all(
                  Theme.of(context).brightness == Brightness.dark ? NothingTheme.black : NothingTheme.white
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _showExtendedIconDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final backgroundColor = isDark ? const Color(0xFF1A1A1A) : NothingTheme.white;
    final inverseBgColor = textColor;
    final inverseTextColor = isDark ? NothingTheme.black : NothingTheme.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('SELECT ICON', style: Theme.of(context).textTheme.displaySmall),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: _allIcons.length,
            itemBuilder: (context, index) {
              final icon = _allIcons[index];
              final isSelected = _selectedIconCode == icon.codePoint;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIconCode = icon.codePoint;
                    if (!_visibleIcons.contains(icon)) {
                      _visibleIcons.insert(0, icon);
                    }
                  });
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? inverseBgColor : backgroundColor,
                    border: Border.all(color: textColor),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected ? inverseTextColor : textColor,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.getFont('JetBrains Mono', color: NothingTheme.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
