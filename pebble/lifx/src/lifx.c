#include <pebble.h>
#include "keys.h"

static Window *main_window;
static Window *bulb_window;
static MenuLayer *main_menu;
static MenuLayer *bulb_menu;

const int LABEL_LEN = 32;
const int MAIN_CELL_HEIGHT = 40;
const int BULB_CELL_HEIGHT = 20;
const int HEADER_HEIGHT = 16;
const int INBOUND_BUFFER_SIZE = 124;
const int OUTBOUND_BUFFER_SIZE = 64;

typedef struct {
	int index;
	bool state;
	char label[32];
} Bulb;

typedef struct {
	int index;
	const char *label;
} Color;

static int bulb_count = 0;
static int color_count = 0;

static bool bulbs_loading = true;
static bool colors_loading = true;

static Bulb *bulbs;
static Color *colors;

/////////////////////////////////////
// App Message
/////////////////////////////////////

static void msg_request_bulbs() {
	DictionaryIterator *iterator = NULL;
	app_message_outbox_begin(&iterator);
	dict_write_cstring(iterator, APPMSG_METHOD_KEY, APPMSG_METHOD_GET_BULBS);
	dict_write_end(iterator);
	app_message_outbox_send();
}

static void begin_reload_bulbs(DictionaryIterator *iterator) {
	bulb_count = 0;
	if (bulbs != NULL) {
		free(bulbs);
	}
	Tuple *count = dict_find(iterator, APPMSG_COUNT_KEY);
	if (count != NULL) {
		bulbs = malloc(count->value->uint8 * sizeof(Bulb));
	}
}

static void append_bulb(DictionaryIterator *iterator) {
	Bulb bulb;
	Tuple *tuple = dict_read_first(iterator);
	while (tuple) {
		switch (tuple->key) {
			case APPMSG_BULB_INDEX_KEY:
				bulb.index = tuple->value->uint8;
				break;
			case APPMSG_BULB_STATE_KEY:
				bulb.state = tuple->value->uint8;
				break;
			case APPMSG_BULB_LABEL_KEY: {
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
		Bulb bulb = bulbs[cell_index->row];
		const char *state = bulb.state ? "On" : "Off";
		menu_cell_basic_draw(ctx, cell_layer, bulb.label, state, NULL);
	}
}

static void main_draw_header(GContext *ctx, const Layer *cell_layer, uint16_t section_index, void *callback_context) {
	menu_cell_basic_header_draw(ctx, cell_layer, "Bulbs");
}

static void main_click(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) {
	window_stack_push(bulb_window, true);
}

static void main_long_click(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) {
	Bulb bulb = bulbs[cell_index->row];
	bulb.state = (bulb.state == 1) ? 0 : 1;
	menu_layer_reload_data(menu_layer);
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
	return 0;
}

static int16_t bulb_cell_height(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *callback_context) {
	return 0;
}

static void bulb_draw_row(GContext *ctx, const Layer *cell_layer, MenuIndex *cell_index, void *callback_context) { 
}

/////////////////////////////////////
// Bulb Window
/////////////////////////////////////

static void bulb_window_load(Window *window) {
	Layer *window_layer = window_get_root_layer(window);
	bulb_menu = menu_layer_create(layer_get_bounds(window_layer));
	menu_layer_set_callbacks(bulb_menu, NULL, (MenuLayerCallbacks) {
		.draw_row = bulb_draw_row,
		.get_cell_height = bulb_cell_height,
		.get_num_rows = bulb_num_rows,
		.get_num_sections = bulb_num_sections,
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
