// license:BSD-3-Clause
// For licensing and usage information, read docs/release/winui_license.txt

//============================================================
//
//  datamap.c - Win32 dialog and options bridge code
//
//============================================================

#include "winui.h"

//============================================================
//  TYPE DEFINITIONS
//============================================================

enum _control_type
{
	CT_UNKNOWN,
	CT_BUTTON,
	CT_STATIC,
	CT_EDIT,
	CT_COMBOBOX,
	CT_TRACKBAR,
	CT_LISTVIEW
};

typedef enum _control_type control_type;
typedef struct _datamap_entry datamap_entry;

struct _datamap_entry
{
	// the basics about the entry
	int dlgitem;
	datamap_entry_type type;
	const char *option_name;
	// callbacks
	datamap_callback callbacks[DCT_COUNT];
	get_option_name_callback get_option_name;
	// formats
	const char *int_format;
	const char *float_format;
	// trackbar options
	bool use_trackbar_options;
	float trackbar_min;
	float trackbar_max;
	float trackbar_increments;
};

struct _datamap
{
	int entry_count;
	datamap_entry entries[256];
};

typedef void (*datamap_default_callback)(datamap *map, HWND control, windows_options &opts, datamap_entry *entry, const char *option_name);

//============================================================
//  PROTOTYPES
//============================================================

static datamap_entry *find_entry(datamap *map, int dlgitem);
static control_type get_control_type(HWND control);
static int control_operation(datamap *map, HWND dialog, windows_options &opts, datamap_entry *entry, datamap_callback_type callback_type);
static void read_control(datamap *map, HWND control, windows_options &opts, datamap_entry *entry, const char *option_name);
static void populate_control(datamap *map, HWND control, windows_options &opts, datamap_entry *entry, const char *option_name);
static char *tztrim(float float_value);

static const datamap_default_callback default_callbacks[DCT_COUNT] =
{
	read_control,
	populate_control,
	NULL
};

//============================================================
//  datamap_create
//============================================================

datamap *datamap_create(void)
{
	datamap *map = (datamap *)malloc(sizeof(*map));

	if (!map)
		return NULL;

	map->entry_count = 0;
	return map;
}

//============================================================
//  datamap_free
//============================================================

void datamap_free(datamap *map)
{
	free(map);
}

//============================================================
//  datamap_add
//============================================================

void datamap_add(datamap *map, int dlgitem, datamap_entry_type type, const char *option_name)
{
	// sanity check for too many entries
	assert(map->entry_count < std::size(map->entries));

	// add entry to the datamap
	memset(&map->entries[map->entry_count], 0, sizeof(map->entries[map->entry_count]));
	map->entries[map->entry_count].dlgitem = dlgitem;
	map->entries[map->entry_count].type = type;
	map->entries[map->entry_count].option_name = option_name;
	map->entry_count++;
}

//============================================================
//  datamap_set_callback
//============================================================

void datamap_set_callback(datamap *map, int dlgitem, datamap_callback_type callback_type, datamap_callback callback)
{
	datamap_entry *entry = find_entry(map, dlgitem);

	assert(callback_type >= 0);
	assert(callback_type < DCT_COUNT);
	entry->callbacks[callback_type] = callback;
}

//============================================================
//  datamap_set_option_name_callback
//============================================================

void datamap_set_option_name_callback(datamap *map, int dlgitem, get_option_name_callback get_option_name)
{
	datamap_entry *entry = find_entry(map, dlgitem);

	entry->get_option_name = get_option_name;
}

//============================================================
//  datamap_set_trackbar_range
//============================================================

void datamap_set_trackbar_range(datamap *map, int dlgitem, float min, float max, float increments)
{
	datamap_entry *entry = find_entry(map, dlgitem);

	entry->use_trackbar_options = true;
	entry->trackbar_min = min;
	entry->trackbar_max = max;
	entry->trackbar_increments = increments;
}

//============================================================
//  datamap_set_int_format
//============================================================

void datamap_set_int_format(datamap *map, int dlgitem, const char *format)
{
	datamap_entry *entry = find_entry(map, dlgitem);

	entry->int_format = format;
}

//============================================================
//  datamap_set_float_format
//============================================================

void datamap_set_float_format(datamap *map, int dlgitem, const char *format)
{
	datamap_entry *entry = find_entry(map, dlgitem);

	entry->float_format = format;
}

//============================================================
//  datamap_read_control
//============================================================

bool datamap_read_control(datamap *map, HWND dialog, windows_options &opts, int dlgitem)
{
	datamap_entry *entry = find_entry(map, dlgitem);

	return control_operation(map, dialog, opts, entry, DCT_READ_CONTROL);
}

//============================================================
//  datamap_read_all_controls
//============================================================

void datamap_read_all_controls(datamap *map, HWND dialog, windows_options &opts)
{
	for (int i = 0; i < map->entry_count; i++)
		control_operation(map, dialog, opts, &map->entries[i], DCT_READ_CONTROL);
}

//============================================================
//  datamap_populate_control
//============================================================

void datamap_populate_control(datamap *map, HWND dialog, windows_options &opts, int dlgitem)
{
	datamap_entry *entry = find_entry(map, dlgitem);

	control_operation(map, dialog, opts, entry, DCT_POPULATE_CONTROL);
}

//============================================================
//  datamap_populate_all_controls
//============================================================

void datamap_populate_all_controls(datamap *map, HWND dialog, windows_options &opts)
{
	for (int i = 0; i < map->entry_count; i++)
		control_operation(map, dialog, opts, &map->entries[i], DCT_POPULATE_CONTROL);
}

//============================================================
//  datamap_update_control
//============================================================

void datamap_update_control(datamap *map, HWND dialog, windows_options &opts, int dlgitem)
{
	datamap_entry *entry = find_entry(map, dlgitem);

	control_operation(map, dialog, opts, entry, DCT_UPDATE_STATUS);
}

//============================================================
//  datamap_update_all_controls
//============================================================

void datamap_update_all_controls(datamap *map, HWND dialog, windows_options &opts)
{
	for (int i = 0; i < map->entry_count; i++)
		control_operation(map, dialog, opts, &map->entries[i], DCT_UPDATE_STATUS);
}

//============================================================
//  find_entry
//============================================================

static datamap_entry *find_entry(datamap *map, int dlgitem)
{
	for (int i = 0; i < map->entry_count; i++)
	{
		if (map->entries[i].dlgitem == dlgitem)
			return &map->entries[i];
	}

	// should not reach here
	assert(false);
	return NULL;
}

//============================================================
//  get_control_type
//============================================================

static control_type get_control_type(HWND control)
{
	control_type type;
	wchar_t class_name[256];

	GetClassName(control, class_name, std::size(class_name));

	if (!_tcscmp(class_name, WC_BUTTON))
		type = CT_BUTTON;
	else if (!_tcscmp(class_name, WC_STATIC))
		type = CT_STATIC;
	else if (!_tcscmp(class_name, WC_EDIT))
		type = CT_EDIT;
	else if (!_tcscmp(class_name, WC_COMBOBOX))
		type = CT_COMBOBOX;
	else if (!_tcscmp(class_name, TRACKBAR_CLASS))
		type = CT_TRACKBAR;
	else if (!_tcscmp(class_name, WC_LISTVIEW))
		type = CT_LISTVIEW;
	else
		type = CT_UNKNOWN;

	assert(type != CT_UNKNOWN);
	return type;
}

//============================================================
//  is_control_displayonly
//============================================================

static bool is_control_displayonly(HWND control)
{
	bool displayonly = false;

	switch(get_control_type(control))
	{
		case CT_STATIC:
			displayonly = true;
			break;

		case CT_EDIT:
			displayonly = (GetWindowLong(control, GWL_STYLE) & ES_READONLY) ? true : false;
			break;

		default:
			displayonly = false;
			break;
	}

	if (!IsWindowEnabled(control))
		displayonly = true;

	return displayonly;
}

//============================================================
//  broadcast_changes
//============================================================

static void broadcast_changes(datamap *map, HWND dialog, windows_options &opts, datamap_entry *entry, const char *option_name)
{
	for (int i = 0; i < map->entry_count; i++)
	{
		// search for an entry with the same option_name, but is not the exact same entry
		const char *that_option_name = map->entries[i].option_name;

		if (map->entries[i].option_name && (&map->entries[i] != entry) && !strcmp(that_option_name, option_name))
		{
			// we've found a control sharing the same option; populate it
			HWND other_control = GetDlgItem(dialog, map->entries[i].dlgitem);

			if (other_control != NULL)
				populate_control(map, other_control, opts, &map->entries[i], that_option_name);
		}
	}
}

//============================================================
//  control_operation
//============================================================

static int control_operation(datamap *map, HWND dialog, windows_options &opts, datamap_entry *entry, datamap_callback_type callback_type)
{
	HWND control = GetDlgItem(dialog, entry->dlgitem);
	int result = 0;

	if (control != NULL)
	{
		// don't do anything if we're reading from a display-only control
		if ((callback_type != DCT_READ_CONTROL) || !is_control_displayonly(control))
		{
			const char *option_name = NULL;
			char option_value[1024];
			char option_name_buffer[64];

			// figure out the option_name
			if (entry->get_option_name != NULL)
			{
				option_name_buffer[0] = '\0';
				entry->get_option_name(map, dialog, control, option_name_buffer, std::size(option_name_buffer));
				option_name = option_name_buffer;
			}
			else
				option_name = entry->option_name;

			// if reading, get the option value, solely for the purposes of comparison
			if ((callback_type == DCT_READ_CONTROL) && (option_name != NULL))
				snprintf(option_value, std::size(option_value), "%s", opts.value(option_name));

			if (entry->callbacks[callback_type] != NULL)
				// use custom callback
				result = entry->callbacks[callback_type](map, dialog, control, opts, option_name);
			else if (default_callbacks[callback_type] && (option_name != NULL))
				// use default callback
				default_callbacks[callback_type](map, control, opts, entry, option_name);

			// the result is dependent on the type of control
			switch(callback_type)
			{
				case DCT_READ_CONTROL:
					// For callbacks that returned true, do not broadcast_changes.
					if (!result) 
					{
						// do a check to see if the control changed
						result = (option_name != NULL) && (strcmp(option_value, opts.value(option_name)) != 0);

						if (result)
						{
							// the value has changed; we may need to broadcast the change
							broadcast_changes(map, dialog, opts, entry, option_name);
						}
					}

					break;

				default:
					// do nothing
					break;
			}
		}
	}

	return result;
}

//============================================================
//  trackbar_value_from_position
//============================================================

static float trackbar_value_from_position(datamap_entry *entry, int position)
{
	float position_f = position;

	if (entry->use_trackbar_options)
		position_f = (position_f * entry->trackbar_increments) + entry->trackbar_min;

	return position_f;
}

//============================================================
//  trackbar_position_from_value
//============================================================

static int trackbar_position_from_value(datamap_entry *entry, float value)
{
	if (entry->use_trackbar_options)
		value = floor((value - entry->trackbar_min) / entry->trackbar_increments + 0.5);

	return (int) value;
}

//============================================================
//  read_control
//============================================================

static void read_control(datamap *map, HWND control, windows_options &opts, datamap_entry *entry, const char *option_name)
{
	int int_value = 0;

	// use default read value behavior
	switch(get_control_type(control))
	{
		case CT_BUTTON:
		{
			assert(entry->type == DM_BOOL);
			bool bool_value = Button_GetCheck(control);
			opts.set_value(option_name, bool_value, OPTION_PRIORITY_CMDLINE);
			break;
		}

		case CT_COMBOBOX:
		{
			int selected_index = ComboBox_GetCurSel(control);

			if (selected_index >= 0)
			{
				switch(entry->type)
				{
					case DM_INT:
						int_value = (int) ComboBox_GetItemData(control, selected_index);
						opts.set_value(option_name, int_value, OPTION_PRIORITY_CMDLINE);
						break;

					case DM_STRING:
					{
						const char *string_value = (const char *) ComboBox_GetItemData(control, selected_index);
						opts.set_value(option_name, string_value ? string_value : "", OPTION_PRIORITY_CMDLINE);
						break;
					}

					default:
						break;
				}
			}

			break;
		}

		case CT_TRACKBAR:
		{
			int trackbar_pos = SendMessage(control, TBM_GETPOS, 0, 0);
			float float_value = trackbar_value_from_position(entry, trackbar_pos);

			switch(entry->type)
			{
				case DM_INT:
					int_value = (int) float_value;

					if (int_value != opts.int_value(option_name)) 
						opts.set_value(option_name, int_value, OPTION_PRIORITY_CMDLINE);

					break;

				case DM_FLOAT:
					// Use tztrim(float_value) or we get trailing zero's that break options_equal().
					if (float_value != opts.float_value(option_name)) 
						opts.set_value(option_name, tztrim(float_value), OPTION_PRIORITY_CMDLINE);

					break;

				default:
					break;
			}

			break;
		}

		case CT_EDIT:
			// NYI
			break;

		case CT_STATIC:
		case CT_LISTVIEW:
		case CT_UNKNOWN:
			// non applicable
			break;
	}
}

//============================================================
//  populate_control
//============================================================

static void populate_control(datamap *map, HWND control, windows_options &opts, datamap_entry *entry, const char *option_name)
{
	int int_value = 0;
	float float_value = 0;
	const char *string_value = NULL;
	char buffer[128];
	int trackbar_pos = 0;

	// use default populate control value
	switch(get_control_type(control))
	{
		case CT_BUTTON:
		{
			assert(entry->type == DM_BOOL);
			bool bool_value = opts.bool_value(option_name);
			Button_SetCheck(control, bool_value);
			break;
		}
		
		case CT_EDIT:
		case CT_STATIC:
			switch(entry->type)
			{
				case DM_STRING:
					string_value = opts.value(option_name);
					break;

				case DM_INT:
					int_value = opts.int_value(option_name);

					if (entry->int_format != NULL)
						snprintf(buffer, std::size(buffer), entry->int_format, int_value);
					else
						snprintf(buffer, std::size(buffer), "%d", int_value);

					string_value = buffer;
					break;

				case DM_FLOAT:
					float_value = opts.float_value(option_name);

					if (entry->float_format != NULL)
						snprintf(buffer, std::size(buffer), entry->float_format, float_value);
					else
						snprintf(buffer, std::size(buffer), "%f", float_value);

					string_value = buffer;
					break;

				default:
					string_value = "";
					break;
			}

			if (string_value == NULL)
				string_value = "";

			winui_set_window_text_utf8(control, string_value);
			break;

		case CT_COMBOBOX:
		{
			int selected_index = 0;
			int i = 0;

			switch(entry->type)
			{
				case DM_INT:
					int_value = opts.int_value(option_name);

					for (i = 0; i < ComboBox_GetCount(control); i++)
					{
						if (int_value == (int) ComboBox_GetItemData(control, i))
						{
							selected_index = i;
							break;
						}
					}
					break;

				case DM_STRING:
					string_value = opts.value(option_name);

					for (i = 0; i < ComboBox_GetCount(control); i++)
					{
						const char *item_string = (const char *) ComboBox_GetItemData(control, i);

						if (!core_stricmp(string_value, item_string ? item_string : ""))
						{
							selected_index = i;
							break;
						}
					}
					
					break;

				default:
					assert(false);
					break;
			}
			
			(void)ComboBox_SetCurSel(control, selected_index);
			break;
		}

		case CT_TRACKBAR:
			// do we specify default options for this control?  if so, we need to specify
			// the range
			if (entry->use_trackbar_options)
			{
				double trackbar_range_d = floor(((entry->trackbar_max - entry->trackbar_min) / entry->trackbar_increments) + 0.5);
				int trackbar_range = (int) trackbar_range_d;
				SendMessage(control, TBM_SETRANGE, true, MAKELPARAM(0, trackbar_range));
			}

			switch(entry->type)
			{
				case DM_INT:
					int_value = opts.int_value(option_name);
					trackbar_pos = trackbar_position_from_value(entry, int_value);
					break;

				case DM_FLOAT:
					float_value = opts.float_value(option_name);
					trackbar_pos = trackbar_position_from_value(entry, float_value);
					break;

				default:
					trackbar_pos = 0;
					assert(false);
					break;
			}
			
			SendMessage(control, TBM_SETPOS, true, trackbar_pos);
			break;

		case CT_LISTVIEW:
		case CT_UNKNOWN:
			// non applicable
			break;
	}
}

// Return a string from a float value with trailing zeros removed.
static char *tztrim(float float_value) 
{
	static char tz_string[20];
	char float_string[20];
	int i = 0;

	snprintf(float_string, std::size(float_string), "%f", float_value);
	char *ptr = float_string;

	// Copy before the '.'
	while (*ptr && *ptr != '.') 
	{
		tz_string[i++] = *ptr++;
	}
	
	// add the '.' and the next digit
	if (*ptr == '.') 
	{
		tz_string[i++] = *ptr++;
		tz_string[i++] = *ptr++;
	}
	
	// Keep copying until we hit a '0'
	while (*ptr && *ptr != '0') 
	{
		tz_string[i++] = *ptr++;
	}
	
	// Null terminate
	tz_string[i] = '\0';
	return tz_string;
}

// mamefx: for coloring of changed elements
const char *datamap_get_control_option_name(datamap *map, HWND dialog, HWND control)
{
	static char option_name_buffer[1024];

	for (int i = 0; i < map->entry_count; i++)
	{
		HWND hCtrl = GetDlgItem(dialog, map->entries[i].dlgitem);
		
		if (hCtrl == control)
		{
			if (map->entries[i].get_option_name)
			{
				option_name_buffer[0] = '\0';
				map->entries[i].get_option_name(map, dialog, control, option_name_buffer, std::size(option_name_buffer));
				return option_name_buffer;
			}

			return map->entries[i].option_name;
		}
	}

	return NULL;
}
