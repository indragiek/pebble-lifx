#include <pebble.h>
#include "keys.h"

static Window *main_window;
static Window *bulb_window;
static MenuLayer *main_menu;
static MenuLayer *bulb_menu;

const int LABEL_LEN = 32;
const int MAIN_CELL_HEIGHT = 40;
const int BULB_CELL_HEIGHT = 30;
const int HEADER_HEIGHT = 16;
const int INBOUND_BUFFER_SIZE = 124;
const int OUTBOUND_BUFFER_SIZE = 124;

#define CUSTOM_COLORS_SECTION 0
#define DEFAULT_COLORS_SECTION 1

typedef struct {
	uint8_t index;
	uint8_t state;
	char label[32];
} Bulb;

typedef struct {
	uint8_t index;
	char label[32];
} Color;

static int bulb_count = 0;
static int custom_color_count = 0;
static int default_color_count = 0;

static bool bulbs_loading = true;
static bool custom_colors_loading = true;
static bool default_colors_loading = true;

static Bulb *bulbs;
static Color *default_colors;
static Color *custom_colors;

static int selected_bulb_index;

/////////////////////////////////////
// App Message
/////////////////////////////////////

static void msg_request_colors(int type) {
	DictionaryIterator *iterator;
	app_message_outbox_begin(&iterator);
	dict_write_cstring(iterator, APPMSG_METHOD_KEY, APPMSG_METHOD_GET_COLORS);
	dict_write_uint8(iterator, APPMSG_COLOR_TYPE_KEY, type);
	dict_write_end(iterator);
	app_message_outbox_send();
}

static void msg_set_color(int colorIndex, int type) {
	DictionaryIterator *iterator;
	app_message_outbox_begin(&iterator);
	dict_write_cstring(iterator, APPMSG_METHOD_KEY, APPMSG_METHOD_UPDATE_BULB_COLOR);
	dict_write_uint8(iterator, APPMSG_COLOR_TYPE_KEY, type);
	dict_write_uint8(iterator, APPMSG_INDEX_KEY, selected_bulb_index);
	dict_write_uint8(iterator, APPMSG_COLOR_INDEX_KEY, colorIndex);
	dict_write_end(iterator);
	app_message_outbox_send();
}

static void begin_reload_colors_array(DictionaryIterator *iterator, Color **colors, int *count, bool *loading) {
	if (*colors != NULL) {
		free(*colors);
	}
	Tuple *colorCount = dict_find(iterator, APPMSG_COUNT_KEY);
	if (count != NULL) {
		*colors = malloc(colorCount->value->uint8 * sizeof(Color));
	}
	*count = 0;
	*loading = true;
	menu_layer_reload_data(bulb_menu);
}


static void begin_reload_colors(DictionaryIterator *iterator) {
	Tuple *type = dict_find(iterator, APPMSG_COLOR_TYPE_KEY);
	if (type != NULL) {
		switch (type->value->uint8) {
			case APPMSG_COLOR_TYPE_CUSTOM:
				begin_reload_colors_array(iterator, &custom_colors, &custom_color_count, &custom_colors_loading);
				break;
			case APPMSG_COLOR_TYPE_DEFAULT:
				begin_reload_colors_array(iterator, &default_colors, &default_color_count, &default_colors_loading);
				break;
		}
	}
}

static void append_color_to_array(DictionaryIterator *iterator, Color **colors, int *count) {
	Color color;
	Tuple *tuple = dict_read_first(iterator);
	while (tuple) {
		switch (tuple->key) {
			case APPMSG_INDEX_KEY:
				color.index = tuple->value->uint8;
				break;
			case APPMSG_LABEL_KEY: {
				uint16_t len = tuple->length;
				strncpy(color.label, tuple->value->cstring, (len < LABEL_LEN) ? len : LABEL_LEN);
				break;
			}
		}
		tuple = dict_read_next(iterator);
	}
	*colors[*count] = color;
	*count = *count + 1;
}

static void append_color(DictionaryIterator *iterator) {
	Tuple *type = dict_find(iterator, APPMSG_COLOR_TYPE_KEY);
	if (type != NULL) {
		switch (type->value->uint8) {
			case APPMSG_COLOR_TYPE_CUSTOM:
				append_color_to_array(iterator, &custom_colors, &custom_color_count);
				break;
			case APPMSG_COLOR_TYPE_DEFAULT:
				append_color_to_array(iterator, &default_colors, &default_color_count);
				break;
		}
	}
}

static void end_reload_colors_array(DictionaryIterator *iterator, bool *loading) {
	*loading = false;
	menu_layer_reload_data(bulb_menu);
}

static void end_reload_colors(DictionaryIterator *iterator) {
	Tuple *type = dict_find(iterator, APPMSG_COLOR_TYPE_KEY);
	if (type != NULL) {
		switch (type->value->uint8) {
			case APPMSG_COLOR_TYPE_CUSTOM:
				end_reload_colors_array(iterator, &custom_colors_loading);
				break;
			case APPMSG_COLOR_TYPE_DEFAULT:
				end_reload_colors_array(iterator, &default_colors_loading);
				break;
		}
	}
}

static void msg_request_bulbs() {
	DictionaryIterator *iterator;
	app_message_outbox_begin(&iterator);
	dict_write_cstring(iterator, APPMSG_METHOD_KEY, APPMSG_METHOD_GET_BULBS);
	dict_write_end(iterator);
	app_message_outbox_send();
}

static void msg_update_bulb_state(Bulb *bulb, uint8_t state) {
	DictionaryIterator *iterator;
	app_message_outbox_begin(&iterator);
	dict_write_cstring(iterator, APPMSG_METHOD_KEY, APPMSG_METHOD_UPDATE_BULB_STATE);
	dict_write_uint8(iterator, APPMSG_INDEX_KEY, bulb->index);
	dict_write_uint8(iterator, APPMSG_BULB_STATE_KEY, state);
	dict_write_end(iterator);
	app_message_outbox_send();
}

static void begin_reload_bulbs(DictionaryIterator *iterator) {
	if (bulbs != NULL) {
		free(bulbs);
	}
	Tuple *count = dict_find(iterator, APPMSG_COUNT_KEY);
	if (count != NULL) {
		bulbs = malloc(count->value->uint8 * sizeof(Bulb));
	}
	bulb_count = 0;
	bulbs_loading = true;
	menu_layer_reload_data(main_menu);
}

static void append_bulb(DictionaryIterator *iterator) {
	Bulb bulb;
	Tuple *tuple = dict_read_first(iterator);
	while (tuple) {
		switch (tuple->key) {
			case APPMSG_INDEX_KEY:
				bulb.index = tuple->value->uint8;
				break;
			case APPMSG_BULB_STATE_KEY:
				bulb.state = tuple->value->uint8;
				break;
			case APPMSG_LABEL_KEY: {
				uint16_t len = tuple->length;
				strncpy(bulb.label, tuple->value->cstring, (len < LABEL_LEN) ? len : LABEL_LEN);
				break;
			}
		}
		tuple = dict_read_next(iterator);
	}
	bulbs[bulb_count] = bulb;
	bulb_count++;
}

static void end_reload_bulbs() {
	bulbs_loading = false;
	menu_layer_reload_data(main_menu);
}

static void msg_inbox_received(DictionaryIterator *iterator, void *context) {
	Tuple *methodTuple = dict_find(iterator, APPMSG_METHOD_KEY);
	if (methodTuple != NULL) {
		char *method = methodTuple->value->cstring;
		if (strcmp(method, APPMSG_METHOD_BEGIN_RELOAD_BULBS) == 0) {
			begin_reload_bulbs(iterator);
		} else if (strcmp(method, APPMSG_METHOD_RECEIVE_BULB) == 0) {
			append_bulb(iterator);
		} else if (strcmp(method, APPMSG_METHOD_END_RELOAD_BULBS) == 0) {
			end_reload_bulbs();
		} else if (strcmp(method, APPMSG_METHOD_BEGIN_RELOAD_COLORS) == 0) {
			begin_reload_colors(iterator);
		} else if (strcmp(method, APPMSG_METHOD_RECEIVE_COLOR) == 0) {
			append_color(iterator);
		} else if (strcmp(method, APPMSG_METHOD_END_RELOAD_COLORS) == 0) {
			end_reload_colors(iterator);
		}
	}
}

static void msg_outbox_sent(DictionaryIterator *iterator, void *context) {
	Tuple *methodTuple = dict_find(iterator, APPMSG_METHOD_KEY);
	if (methodTuple != NULL) {
		char *method = methodTuple->value->cstring;
		if (strcmp(method, APPMSG_METHOD_UPDATE_BULB_STATE) == 0) {
			Tuple *index = dict_find(iterator, APPMSG_INDEX_KEY);
			Tuple *state = dict_find(iterator, APPMSG_BULB_STATE_KEY);
			if (index != NULL && state != NULL) {
				Bulb *bulb = &bulbs[index->value->uint8];
				bulb->state = state->value->uint8;
				menu_layer_reload_data(main_menu);
			}
		}
	}
}

/////////////////////////////////////
// Main Menu
/////////////////////////////////////

static uint16_t main_num_sections(struct MenuLayer *menu_layer, void *callback_context) {
	return 1;
}

static uint16_t main_num_rows(struct MenuLayer *menu_layer, uint16_t section_index, void *callback_context) {
	if (bulbs_loading) {
		return 1;
	}
	return bulb_count;
}

static int16_t main_cell_height(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) {
	return MAIN_CELL_HEIGHT;
}

static int16_t main_header_height(struct MenuLayer *menu_layer, uint16_t section_index, void *callback_context) {
	return HEADER_HEIGHT;
}

static void main_draw_row(GContext *ctx, const Layer *cell_layer, MenuIndex *cell_index, void *callback_context) {
	if (bulbs_loading) {
		menu_cell_basic_draw(ctx, cell_layer, "Loading...", NULL, NULL);
	} else {
		Bulb *bulb = &bulbs[cell_index->row];
		const char *state = bulb->state ? "On" : "Off";
		menu_cell_basic_draw(ctx, cell_layer, bulb->label, state, NULL);
	}
}

static void main_draw_header(GContext *ctx, const Layer *cell_layer, uint16_t section_index, void *callback_context) {
	menu_cell_basic_header_draw(ctx, cell_layer, "Bulbs");
}

static void main_click(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) {
	if (!bulbs_loading) {
		window_stack_push(bulb_window, true);
		selected_bulb_index = cell_index->row;
		msg_request_colors(APPMSG_COLOR_TYPE_CUSTOM);
		//msg_request_colors(APPMSG_COLOR_TYPE_DEFAULT);
	}
}

static void main_long_click(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) {
	Bulb *bulb = &bulbs[cell_index->row];
	msg_update_bulb_state(bulb, (bulb->state == 1) ? 0 : 1);
}

/////////////////////////////////////
// Main Window
/////////////////////////////////////

static void main_window_load(Window *window) {
	Layer *window_layer = window_get_root_layer(window);
	main_menu = menu_layer_create(layer_get_bounds(window_layer));
	menu_layer_set_callbacks(main_menu, NULL, (MenuLayerCallbacks) {
		.draw_row = main_draw_row,
		.draw_header = main_draw_header,
		.get_cell_height = main_cell_height,
		.get_header_height = main_header_height,
		.get_num_rows = main_num_rows,
		.get_num_sections = main_num_sections,
		.select_click = main_click,
		.select_long_click = main_long_click,
	});
	menu_layer_set_click_config_onto_window(main_menu, window);
	layer_add_child(window_layer, menu_layer_get_layer(main_menu));
	msg_request_bulbs();
}

static void main_window_unload(Window *window) {
	menu_layer_destroy(main_menu);
}

/////////////////////////////////////
// Bulb Menu
/////////////////////////////////////

static uint16_t bulb_num_sections(struct MenuLayer *menu_layer, void *callback_context) {
	return 2;
}

static uint16_t bulb_num_rows(struct MenuLayer *menu_layer, uint16_t section_index, void *callback_context) {
	switch (section_index) {
		case CUSTOM_COLORS_SECTION:
			return custom_colors_loading ? 1 : custom_color_count;
		case DEFAULT_COLORS_SECTION:
			return default_colors_loading ? 1 : default_color_count;
		default:
			return 0;
	}
}

static int16_t bulb_cell_height(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) {
	return BULB_CELL_HEIGHT;
}

static int16_t bulb_header_height(struct MenuLayer *menu_layer, uint16_t section_index, void *callback_context) {
	return HEADER_HEIGHT;
}

static void bulb_draw_row(GContext *ctx, const Layer *cell_layer, MenuIndex *cell_index, void *callback_context) { 
	switch (cell_index->section) {
		case CUSTOM_COLORS_SECTION: {
			Color *color = &custom_colors[cell_index->row];
			menu_cell_basic_draw(ctx, cell_layer, custom_colors_loading ? "Loading" : color->label, NULL, NULL);
			break;
		}
		case DEFAULT_COLORS_SECTION: {
			Color *color = &default_colors[cell_index->row];
			menu_cell_basic_draw(ctx, cell_layer, default_colors_loading ? "Loading" : color->label, NULL, NULL);
			break;
		}
		default:
			break;
	}
}

static void bulb_draw_header(GContext *ctx, const Layer *cell_layer, uint16_t section_index, void *callback_context) {
	switch (section_index) {
		case DEFAULT_COLORS_SECTION:
			menu_cell_basic_header_draw(ctx, cell_layer, "Default Colors");
			break;
		case CUSTOM_COLORS_SECTION:
			menu_cell_basic_header_draw(ctx, cell_layer, "Custom Colors");
			break;
		default:
			break;
	}
}

static void bulb_click(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) {
	switch (cell_index->section) {
		case CUSTOM_COLORS_SECTION: {
			if (!custom_colors_loading) {
				msg_set_color(cell_index->row, APPMSG_COLOR_TYPE_CUSTOM);
			}
			break;
		}
		case DEFAULT_COLORS_SECTION: {
			if (!default_colors_loading) {
				msg_set_color(cell_index->row, APPMSG_COLOR_TYPE_DEFAULT);
			}
			break;
		}
		default:
			break;
	}
}

/////////////////////////////////////
// Bulb Window
/////////////////////////////////////

static void bulb_window_load(Window *window) {
	Layer *window_layer = window_get_root_layer(window);
	bulb_menu = menu_layer_create(layer_get_bounds(window_layer));
	menu_layer_set_callbacks(bulb_menu, NULL, (MenuLayerCallbacks) {
		.draw_row = bulb_draw_row,
		.draw_header = bulb_draw_header,
		.get_cell_height = bulb_cell_height,
		.get_header_height = bulb_header_height,
		.get_num_rows = bulb_num_rows,
		.get_num_sections = bulb_num_sections,
		.select_click = bulb_click,
	});
	menu_layer_set_click_config_onto_window(bulb_menu, window);
	layer_add_child(window_layer, menu_layer_get_layer(bulb_menu));
}

static void bulb_window_unload(Window *window) {
	menu_layer_destroy(bulb_menu);
}

/////////////////////////////////////
// Initialization
/////////////////////////////////////

static void init(void) {
	app_message_register_inbox_received(msg_inbox_received);
	app_message_register_outbox_sent(msg_outbox_sent);
	app_message_open(INBOUND_BUFFER_SIZE, OUTBOUND_BUFFER_SIZE);

	main_window = window_create();
	window_set_window_handlers(main_window, (WindowHandlers) {
		.load = main_window_load,
		.unload = main_window_unload,
	});

	bulb_window = window_create();
	window_set_window_handlers(bulb_window, (WindowHandlers) {
		.load = bulb_window_load,
		.unload = bulb_window_unload,
	});
	window_stack_push(main_window, true);
}

static void deinit(void) {
	window_destroy(main_window);
	window_destroy(bulb_window);
}

int main(void) {
	init();
	APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", main_window);
	app_event_loop();
	deinit();
}
