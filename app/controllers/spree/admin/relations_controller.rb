module Spree
  module Admin
    class RelationsController < BaseController
      before_filter :load_data, :only => [:create, :destroy]

      respond_to :js, :html

      def create
        @relation = Relation.new(relation_params)
        @relation.relatable = @product
        @relation.related_to = Spree::Variant.find(relation_params[:related_to_id]).product
        @relation.save

        respond_with(@relation)
      end

      def update
        @relation = Relation.find(params[:id])
        @relation.update_attribute :discount_amount, relation_params[:discount_amount] || 0

        redirect_to( related_admin_product_url(@relation.relatable) )
      end

      def update_positions
        params[:positions].each do |id, index|
          model_class.where(:id => id).update_all(:position => index)
        end
    
        respond_to do |format|
          format.js  { render :text => 'Ok' }
        end
      end

      def destroy
        @relation = Relation.find(params[:id])
        
        if @relation.destroy
          flash[:success] = Spree.t(:successfully_removed, :resource => Spree.t(:product_relation))
        end
        
        respond_to do |format|
          format.html { redirect_to related_admin_product_path(@product)}
          format.js   { render :layout => false }
        end
      end

      private

      def relation_params
        params.require(:relation).permit(:related_to, :relation_type, :relatable, :related_to_id, :discount_amount, :relation_type_id, :related_to_type, :position)
      end

      def load_data
        @product = Spree::Product.find_by_permalink(params[:product_id])
      end

      def model_class
        Spree::Relation
      end
    end
  end
end
