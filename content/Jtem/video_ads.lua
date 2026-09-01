SMODS.Videos = {}

-- if someone has better idea please change this
local function load_video_from_NFS(file_path, file_name)
    local data = NFS.read('data', file_path)
    love.filesystem.createDirectory( "video_cache" )
    local temp_file_path = "video_cache/"..file_name
    love.filesystem.write(temp_file_path, data)
    local video_data = love.video.newVideoStream(temp_file_path)
    love.filesystem.remove(temp_file_path)
    return video_data
end

SMODS.Video = SMODS.GameObject:extend{
    obj_table = SMODS.Videos,
    obj_buffer = {},
    disable_mipmap = false,
    required_params = {
        'key',
        'path',
        'px',
        'py'
    },
    set = 'Video',
    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end
        if self.language then
            self.key_noloc = self.key
            self.key = ('%s_%s'):format(self.key, self.language)
        end
        -- needed for changing high contrast settings, apparently
        self.name = self.key
        SMODS.Atlas.super.register(self)
    end,
    inject = function(self)
        local file_path = type(self.path) == 'table' and
            ((G.SETTINGS.real_language and self.path[G.SETTINGS.real_language]) or self.path[G.SETTINGS.language] or self.path['default'] or self.path['en-us']) or self.path
        if file_path == 'DEFAULT' then return end
        -- language specific sprites override fully defined sprites only if that language is set
        if self.language and G.SETTINGS.language ~= self.language and G.SETTINGS.real_language ~= self.language then return end
        if not self.language and (self.obj_table[('%s_%s'):format(self.key, G.SETTINGS.language)] or self.obj_table[('%s_%s'):format(self.key, G.SETTINGS.real_language)]) then return end
        self.full_path = (self.mod and self.mod.path or SMODS.path) ..
            'assets/videos/'.. file_path
        self.video_stream = assert(load_video_from_NFS(self.full_path,file_path),
            ('Failed to create video stream for Video %s'):format(self.key))
        -- Handled by ad creation
        -- self.video = love.graphics.newVideo(self.video_stream)
        -- Shortcut this to self.image so this works out of the box for Sprites
        -- self.image = self.video
        SMODS.Videos[self.key_noloc or self.key] = self
    end,
    process_loc_text = function() end,
    pre_inject_class = function(self)
        G:set_render_settings() -- restore originals first in case a texture pack was disabled
    end
}

local sprite_reset_ref = Sprite.reset
function Sprite:reset()
    if self.atlas and self.atlas.video then
        self.atlas = SMODS.Videos[self.atlas.name]
        self:set_sprite_pos(self.sprite_pos)
        return
    end
    sprite_reset_ref(self)
end

SMODS.Video {
    key = "paket_balala",
    path = "ad_paket.ogv",
    px = 240,
    py = 240,
}